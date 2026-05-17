import json

import util

server_dir = util.base_path / "server"


class JSWispServer:
    name = "wisp-js"
    path = server_dir / "js"

    def install(self):
        self.path.mkdir(parents=True, exist_ok=True)
        util.run(["npm", "i"], cwd=self.path)

    def is_installed(self):
        return (self.path / "node_modules").exists()

    def run(self, port, log):
        return util.run_bg(["node", "server.mjs", str(port)], log_path=log, cwd=self.path)


class PythonWispServer:
    name = "wisp-server-python"
    path = server_dir / "python"

    def __init__(self, python="python3"):
        self.python = python
        if self.python != "python3":
            self.name = f"{self.name} ({self.python})"
        self.git_repo = self.path / "wisp-server-python"
        self.venv = self.path / f".venv_{python}"

    def _pip(self):
        """Path to pip inside the venv."""
        bin_dir = "Scripts" if util.IS_WINDOWS else "bin"
        return self.venv / bin_dir / "pip"

    def _python(self):
        """Path to python inside the venv."""
        bin_dir = "Scripts" if util.IS_WINDOWS else "bin"
        name = "python.exe" if util.IS_WINDOWS else "python3"
        return self.venv / bin_dir / name

    def install(self):
        self.path.mkdir(parents=True, exist_ok=True)
        if not self.git_repo.exists():
            util.run(["git", "clone",
                      "https://github.com/MercuryWorkshop/wisp-server-python",
                      self.git_repo])
        util.run([self.python, "-m", "venv", self.venv], cwd=self.git_repo)
        util.run([self._pip(), "install", "-e", "."], cwd=self.git_repo)

    def is_installed(self):
        return self.venv.exists()

    def run(self, port, log):
        return util.run_bg(
            [self._python(), "-m", "wisp.server", f"--port={port}", "--allow-loopback"],
            log_path=log, cwd=self.git_repo,
        )


class RustWispServer:
    name = "epoxy-server"
    path = server_dir / "rust"

    def __init__(self, threading):
        self.threading = threading
        self.name = f"{self.name} ({threading})"
        self.src_dir = self.path / "server"

    def install(self):
        if not self.path.exists():
            util.run(["git", "clone",
                      "https://github.com/MercuryWorkshop/epoxy-tls",
                      self.path])
        util.run(["cargo", "build", "--release"], cwd=self.src_dir)

    def is_installed(self):
        binary = "epoxy-server.exe" if util.IS_WINDOWS else "epoxy-server"
        return (self.path / "target" / "release" / binary).exists()

    def run(self, port, log):
        config_toml = (
            f'[server]\nbind = ["tcp", "127.0.0.1:{port}"]\nruntime = "{self.threading}"\n'
        )
        config_path = self.src_dir / "config.toml"
        config_path.write_text(config_toml)
        binary = "epoxy-server.exe" if util.IS_WINDOWS else "epoxy-server"
        return util.run_bg(
            [self.path / "target" / "release" / binary, config_path],
            log_path=log, cwd=self.src_dir,
        )


class GoWispServer:
    name = "mrrowisp"
    path = server_dir / "go"

    def install(self):
        if not self.path.exists():
            util.run(["git", "clone",
                      "https://github.com/starlightdevgroup/mrrowisp",
                      self.path])
        util.run(["go", "get", "."], cwd=self.path)
        util.run(["go", "build", "-o", "mrrowisp"], cwd=self.path)

    def is_installed(self):
        binary = "mrrowisp.exe" if util.IS_WINDOWS else "mrrowisp"
        return (self.path / binary).exists()

    def run(self, port, log):
        config = {
            "port": port,
            "allowTCP": True,
            "allowUDP": True,
            "allowDirectIP": True,
            "allowPrivateIPs": True,
            "allowLoopbackIPs": True,
            "tcpBufferSize": 131072,
            "bufferRemainingLength": 131072,
            "tcpNoDelay": True,
            "websocketTcpNoDelay": True,
            "blacklist": {"hostnames": [], "ports": []},
            "whitelist": {"hostnames": [], "ports": []},
            "proxy": "",
            "websocketPermessageDeflate": False,
            "dnsServers": [],
            "enableV2": False,
            "motd": "",
            "passwordAuth": False,
            "passwordAuthRequired": False,
            "passwordUsers": {},
            "certAuth": False,
            "certAuthRequired": False,
            "certAuthPublicKeys": [],
            "enableStreamConfirm": False,
            "banEnabled": False,
            "parseRealIP": False,
            "bandwidthLimitKbps": 0,
            "connectionsLimitPerIP": 0,
            "connectionWindowSeconds": 0,
            "maxConnectsPerSecond": 2147483647,
            "streamLimitPerHost": 0,
            "streamLimitTotal": 0,
            "maxPacketRate": 2147483647,
            "maxConnectionLifetimeSeconds": 0,
            "maxStreamsPerConnection": 0,
            "maxConnectionsPerIP": 0,
            "globalMaxConnections": 0,
            "writeQueueSize": 0,
            "maxInboundBytesPerSecond": 0,
            "logLevel": "debug",
        }
        config_path = self.path / "config.json"
        config_path.write_text(json.dumps(config))
        binary = "mrrowisp.exe" if util.IS_WINDOWS else "mrrowisp"
        return util.run_bg([self.path / binary, "--config", str(config_path)], log_path=log, cwd=self.path)


class CustomWispServer:
    def __init__(self, name, path):
        self.name = name
        self.path = pathlib.Path(path)

    def install(self):
        pass

    def is_installed(self):
        return True

    def run(self, port, log):
        return util.run_bg([self.path, str(port)], log_path=log)


implementations = [
    JSWispServer(),
    PythonWispServer(),
    RustWispServer("singlethread"),
    RustWispServer("multithread"),
    GoWispServer(),
]
