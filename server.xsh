#!/usr/bin/env xonsh

import util

server_dir = util.base_path / "server"

class NodeWispServer:
  name = "wisp-server-node"
  path = server_dir / "node"

  def install(self):
    mkdir -p @(self.path)
    with util.temp_cd(self.path):  
      npm i
  
  def is_installed(self):
    return (self.path / "node_modules").exists()
  
  def run(self, port, log):
    with util.temp_cd(self.path):  
      node server.js @(port) 2>&1 >@(log) &
      return util.last_job()


class PythonWispServer:
  name = "wisp-server-python"
  path = server_dir / "python"
  git_repo = path / name

  def __init__(self, python):
    self.python = python
    self.name = f"{self.name} ({python})"
    self.venv = self.path / f".venv_{python}"

  def install(self):
    mkdir -p @(self.path)
    if not self.git_repo.exists():
      git clone "https://github.com/MercuryWorkshop/wisp-server-python" @(self.git_repo)

    with util.temp_cd(self.git_repo):  
      @(self.python) -m venv @(self.venv)
      bash -c @(f"source {self.venv}/bin/activate; pip3 install -r requirements.txt")
  
  def is_installed(self):
    return self.venv.exists()
  
  def run(self, port, log):
    with util.temp_cd(self.git_repo):
      bash -c @(f"source {self.venv}/bin/activate; {self.python} main.py --port={port} --allow-loopback 2>&1 >'{log}'") &
      return util.last_job()


class RustWispServer:
  name = "epoxy-server"
  path = server_dir / "rust"
  src_dir = path / "server"

  def install(self):
    if not self.path.exists():
      git clone "https://github.com/MercuryWorkshop/epoxy-tls" @(self.path)
    with util.temp_cd(self.src_dir):
      cargo build --release
      touch installed

  def is_installed(self):
    return (self.src_dir / "installed").exists()
  
  def run(self, port, log):
    with util.temp_cd(self.src_dir):
      cargo r -r -- --port=@(port) --host=127.0.0.1 2>&1 >@(log) &
      return util.last_job()

class CPPWispServer:
  name = "WispServerCpp"
  path = server_dir / "cpp"
  git_repo = path / name
  lib_repo = path / "uWebSockets"
  prefix = path / "prefix"

  def install(self):
    core_count = $(nproc --all).strip()
    if not self.git_repo.exists():
      git clone "https://github.com/FoxMoss/WispServerCpp" @(self.git_repo)
    if not self.lib_repo.exists():
      git clone "https://github.com/uNetworking/uWebSockets" @(self.lib_repo) --recurse-submodules --shallow-submodules
    if not (self.prefix / "lib" / "libusockets.a").exists():
      with util.temp_cd(self.lib_repo):
        mkdir -p @(self.prefix)/lib
        mkdir -p @(self.prefix)/include
        make examples -j@(core_count)
        make DESTDIR=@(self.prefix) prefix= install
        cp ./uSockets/uSockets.a @(self.prefix)/lib/libusockets.a
        cp ./uSockets/src/*.h @(self.prefix)/include/
    with util.temp_cd(self.git_repo):
      #why is the L not capitalized?
      mkdir -p obj
      make all FlAGS=@(f"-L{self.prefix / 'lib'} -I{self.prefix / 'include'}") -j@(core_count)
      
  def is_installed(self):
    return (self.git_repo / "wispserver").exists()
  
  def run(self, port, log):
    with util.temp_cd(self.git_repo):
      ./wispserver @(port) 2>&1 >@(log) &
      return util.last_job()

implementations = [
  NodeWispServer(),
  PythonWispServer("python3"),
  PythonWispServer("pypy3"),
  RustWispServer(),
  CPPWispServer()
]

