#!/usr/bin/env xonsh

import json

import util

server_dir = util.base_path / "server"

class JSWispServer:
  name = "wisp-js"
  path = server_dir / "js"

  def install(self):
    mkdir -p @(self.path)
    with util.temp_cd(self.path):  
      npm i
  
  def is_installed(self):
    return (self.path / "node_modules").exists()
  
  def run(self, port, log):
    with util.temp_cd(self.path):  
      node server.mjs @(port) 2>&1 >@(log) &
      return util.last_job()

class PythonWispServer:
  name = "wisp-server-python"
  path = server_dir / "python"
  git_repo = path / name

  def __init__(self, python="python3"):
    self.python = python
    if self.python != "python3":
      self.name = f"{self.name} ({self.python})"
    self.venv = self.path / f".venv_{python}"

  def install(self):
    mkdir -p @(self.path)
    if not self.git_repo.exists():
      git clone "https://github.com/MercuryWorkshop/wisp-server-python" @(self.git_repo)

    with util.temp_cd(self.git_repo):  
      @(self.python) -m venv @(self.venv)
      bash -c @(f"source {self.venv}/bin/activate; pip3 install -e .")
  
  def is_installed(self):
    return self.venv.exists()
  
  def run(self, port, log):
    with util.temp_cd(self.git_repo):
      bash -c @(f"source {self.venv}/bin/activate; python3 -m wisp.server --port={port} --allow-loopback 2>&1 >'{log}'") &
      return util.last_job()


class RustWispServer:
  name = "epoxy-server"
  path = server_dir / "rust"
  src_dir = path / "server"

  def __init__(self, threading):
    self.threading = threading
    self.name = f"{self.name} ({threading})"

  def install(self):
    if not self.path.exists():
      git clone "https://github.com/MercuryWorkshop/epoxy-tls" @(self.path)
    with util.temp_cd(self.src_dir):
      cargo build --release

  def is_installed(self):
    return (self.path / "target" / "release" / "epoxy-server").exists()
  
  def run(self, port, log):
    with util.temp_cd(self.src_dir):
      echo @(f"[server]\nbind = [\"tcp\", \"127.0.0.1:{port}\"]\nruntime = \"{self.threading}\"") > config.toml
      @(self.path / "target" / "release" / "epoxy-server") config.toml >@(log) &
      return util.last_job()

class GoWispServer:
  name = "go-wisp"
  path = server_dir / "go"

  def install(self):
    if not self.path.exists():
      git clone "https://github.com/TheFalloutOf76/go-wisp" @(self.path)
    with util.temp_cd(self.path):
      go get .
      go build -ldflags "-s -w" -o "go-wisp" main.go

  def is_installed(self):
    return (self.path / "go-wisp").exists()
  
  def run(self, port, log):
    config = {
      "port": str(port),
      "disableUDP": True,
      "tcpBufferSize": 131072,
      "bufferRemainingLength": 256,
      "tcpNoDelay": False,
      "websocketTcpNoDelay": False,
      "blacklist": {
          "hostnames": []
      },
      "whitelist": {
          "hostnames": []
      },
      "proxy": "",
      "websocketPermessageDeflate": False,
      "dnsServer": ""
    }

    config_content = json.dumps(config)
    config_path = self.path / "config.json"
    config_path.write_text(config_content)
    
    with util.temp_cd(self.path):
      ./go-wisp 2>&1 >@(log) &
      return util.last_job()

class CustomWispServer:
  def __init__(self, name, path):
    self.name = name
    self.path = path

  def install(self):
    pass
  
  def is_installed(self):
    return True
  
  def run(self, port, log):
    @(self.path) @(port) 2>&1 >@(log) &
    return util.last_job()

implementations = [
  JSWispServer(),
  PythonWispServer(),
  RustWispServer("singlethread"),
  RustWispServer("multithread"),
  GoWispServer(),
]

