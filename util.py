import pathlib
import contextlib
import platform
import re
import os
import subprocess
import time
import signal

base_path = pathlib.Path(__file__).resolve().parent
IS_WINDOWS = platform.system() == "Windows"


def run(cmd, **kwargs):
    """Run a command list, raising on non-zero exit.

    cmd must be a list of strings/Paths so that arguments with spaces are
    passed correctly without shell quoting issues.
    """
    cmd = [str(c) for c in cmd]
    return subprocess.run(cmd, check=True, **kwargs)


def run_bg(cmd, log_path=None, cwd=None):
    """Start a command list in the background.

    stdout and stderr are redirected to log_path when provided.
    """
    cmd = [str(c) for c in cmd]
    stdout = open(log_path, "w") if log_path else subprocess.DEVNULL
    stderr = subprocess.STDOUT if log_path else subprocess.DEVNULL

    kwargs = dict(stdout=stdout, stderr=stderr, cwd=cwd)
    if not IS_WINDOWS:
        kwargs["preexec_fn"] = os.setsid

    return subprocess.Popen(cmd, **kwargs)


def kill_process(proc):
    """Terminate a background Popen process (and its process group on Unix)."""
    if proc is None:
        return
    if IS_WINDOWS:
        try:
            proc.terminate()
        except OSError:
            pass
    else:
        try:
            os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
        except (ProcessLookupError, PermissionError):
            pass


def kill_by_port(target_port):
    """Kill whatever process is listening on target_port."""
    if IS_WINDOWS:
        result = subprocess.run(
            ["netstat", "-ano"],
            capture_output=True, text=True,
        )
        for line in result.stdout.splitlines():
            if "LISTENING" in line and f":{target_port}" in line:
                parts = line.split()
                pid = parts[-1]
                try:
                    subprocess.run(["taskkill", "/F", "/PID", pid], check=True)
                except subprocess.CalledProcessError:
                    pass
    else:
        result = subprocess.run(
            ["sudo", "netstat", "-tulpn"],
            capture_output=True, text=True,
        )
        process_regex = r":(\d+).+?(\d+)/"
        for port, pid in re.findall(process_regex, result.stdout):
            if int(port) == target_port:
                try:
                    subprocess.run(["kill", "-s", "SIGTERM", pid], check=True)
                except subprocess.CalledProcessError:
                    pass


def measure_bandwidth(port, duration):
    """Return bytes/second of TCP traffic on *port* over *duration* seconds."""
    start = time.time()
    result = subprocess.run(
        [
            "sudo", "timeout", str(duration * 2),
            "iftop", "-i", "lo", "-f", f"port {port}",
            "-t", "-s", str(duration), "-B",
        ],
        capture_output=True, text=True,
    )
    iftop_out = result.stderr + result.stdout
    end = time.time()

    iftop_regex = r"Cumulative.+?:.+?([\d.]+)([A-Z]+)\n"
    unit_names = ["B", "KB", "MB", "GB", "TB"]
    match = re.findall(iftop_regex, iftop_out)
    if not match:
        raise RuntimeError("iftop produced no readable output")
    amount, unit = match[0]
    multiplier = 1024 ** unit_names.index(unit)
    return float(amount) * multiplier / (end - start)


@contextlib.contextmanager
def temp_cd(path):
    original_path = os.getcwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(original_path)


def is_wsl():
    binfmt_path = pathlib.Path("/proc/sys/fs/binfmt_misc/")
    try:
        return bool(list(binfmt_path.rglob("WSL*")))
    except (PermissionError, OSError):
        return False


def get_cpu():
    if IS_WINDOWS or is_wsl():
        powershell_cmd = (
            "Get-CimInstance -ClassName Win32_Processor "
            "| Select-Object -ExpandProperty Name"
        )
        if is_wsl():
            powershell_path = "/mnt/c/Windows/System32/WindowsPowershell/v1.0/powershell.exe"
        else:
            powershell_path = "powershell.exe"
        cpu_name = subprocess.check_output(
            [powershell_path, "-command", powershell_cmd], text=True
        ).strip()
        if IS_WINDOWS:
            cpu_count = os.cpu_count() or 1
            return f"{cpu_name} (x{cpu_count})"
    else:
        cpu_regex = r"model name.+?: (.+?)\n"
        cpuinfo = pathlib.Path("/proc/cpuinfo").read_text()
        cpu_names = re.findall(cpu_regex, cpuinfo)
        if not cpu_names:
            cpu_arch = subprocess.check_output(["uname", "-m"], text=True).strip()
            cpu_name = f"Unknown {cpu_arch} CPU"
        else:
            cpu_name = cpu_names[0]

    count_regex = r"processor.+?: (.+?)\n"
    cpu_count = len(re.findall(count_regex, pathlib.Path("/proc/cpuinfo").read_text()))
    return f"{cpu_name} (x{cpu_count})"
