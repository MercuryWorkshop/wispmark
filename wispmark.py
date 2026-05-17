#!/usr/bin/env python3

import os
import socket
import sys
import subprocess
import traceback
import time
import argparse
import textwrap

import requests

import server
import client
import util

wisp_port = 6001
echo_port = 6002
server_timeout = 5
test_duration = 10
print_md = False
output_file = "wispmark-results.md"

echo_dir = util.base_path / "echo"
echo_repo = echo_dir / "tokio"


def install_echo():
    echo_dir.mkdir(parents=True, exist_ok=True)
    if echo_repo.exists():
        return
    util.run(["git", "clone", "https://github.com/tokio-rs/tokio", echo_repo])
    util.run(["cargo", "build", "--release", "--example", "echo-tcp"], cwd=echo_repo)


def run_echo():
    return util.run_bg(
        ["cargo", "run", "--release", "--example", "echo-tcp",
         f"127.0.0.1:{echo_port}"],
        cwd=echo_repo,
    )


def wait_for_server():
    for _ in range(int(server_timeout / 0.5)):
        try:
            requests.get(f"http://127.0.0.1:{wisp_port}/", timeout=0.5)
            return
        except Exception:
            time.sleep(0.5)
    raise RuntimeError("Server failed to start in time.")


def wait_for_socket():
    for _ in range(int(server_timeout / 0.5)):
        s = socket.socket()
        try:
            s.connect(("127.0.0.1", echo_port))
            s.close()
            return
        except OSError:
            time.sleep(0.5)
    raise RuntimeError("Echo server failed to start in time.")


def get_table(table, use_md):
    corner_separator = "-|-" if use_md else "-+-"
    col_widths = [
        max(len(table[y][x]) for y in range(len(table)))
        for x in range(len(table[0]))
    ]

    rows = []
    for row in table:
        cells = [cell.ljust(col_widths[x]) for x, cell in enumerate(row)]
        row_str = " | ".join(cells)
        if use_md:
            row_str = f"| {row_str} |"
        rows.append(row_str)

    row_separator = corner_separator.join("-" * w for w in col_widths) + "-"
    if use_md:
        row_separator = f"|-{row_separator}|"

    if use_md:
        table_str = f"\n{row_separator}\n".join(rows[:2])
        table_str += "\n" + "\n".join(rows[2:])
    else:
        table_str = f"\n{row_separator}\n".join(rows)

    return table_str


def main():
    if not util.IS_WINDOWS:
        util.run(["sudo", "true"])
    install_echo()
    echo_process = run_echo()
    wait_for_socket()

    for implementation in server.implementations + client.implementations:
        if implementation.is_installed():
            continue
        print(f"installing {implementation.name}")
        implementation.install()

    log_dir = util.base_path / "log"
    log_dir.mkdir(parents=True, exist_ok=True)

    table = [[""] + [impl.name for impl in client.implementations]]
    client_jobs = []
    server_job = None

    for server_impl in server.implementations:
        table.append([server_impl.name])
        for client_impl in client.implementations:
            print(f"testing {server_impl.name} with {client_impl.name}")
            server_log = log_dir / f"SERVER_{server_impl.name}_{client_impl.name}.log"
            client_log = log_dir / f"CLIENT_{server_impl.name}_{client_impl.name}.log"
            client_jobs = []

            try:
                print("starting server")
                util.kill_by_port(wisp_port)
                time.sleep(1)
                server_job = server_impl.run(wisp_port, server_log)
                wait_for_server()

                print("running client and recording speeds...")
                client_jobs = client_impl.run(wisp_port, echo_port, client_log)

                time.sleep(1)
                speed = util.measure_bandwidth(echo_port, test_duration)
                result = f"{round(speed / (1024 ** 2), 2)} MiB/s"
                print(f"result: {result}")

            except (subprocess.CalledProcessError, RuntimeError) as e:
                print("error: failure to measure bandwidth. the wisp server may not have started properly.")
                print(e)
                result = "DNF"

            table[-1].append(result)
            util.kill_process(server_job)
            for j in client_jobs:
                util.kill_process(j)

    util.kill_process(echo_process)

    print("WispMark has finished.")
    starter = textwrap.dedent(f"""
    CPU: {util.get_cpu()}
    Test duration: {test_duration}s
    """)
    print(starter)
    print(get_table(table, print_md))
    with open(output_file, "w") as f:
        f.write("```" + starter + "```\n")
        f.write(get_table(table, True))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="A benchmarking tool for Wisp protocol implementations.")
    parser.add_argument("--duration", default=test_duration, type=int,
                        help=f"Duration of each test in seconds. Default: {test_duration}s.")
    parser.add_argument("--output", default=output_file,
                        help=f"Output file for results. Default: {output_file}.")
    parser.add_argument("--print-md", default=False, action="store_true",
                        help="Print a markdown table after test results are complete.")
    args = parser.parse_args()
    test_duration = args.duration
    print_md = args.print_md
    output_file = args.output

    try:
        main()
    except Exception:
        traceback.print_exc()
