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
      node server.mjs @(port) 2>&1 >@(log) &
      return util.last_job()


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
      bash -c @(f"source {self.venv}/bin/activate; pip3 install -e .")
  
  def is_installed(self):
    return self.venv.exists()
  
  def run(self, port, log):
    with util.temp_cd(self.git_repo):
      bash -c @(f"source {self.venv}/bin/activate; {self.python} -m wisp.server --port={port} --allow-loopback 2>&1 >'{log}'") &
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
      $RUSTFLAGS="--cfg tokio_unstable"
      cargo build --release

  def is_installed(self):
    return (self.path / "target" / "release" / "epoxy-server").exists()
  
  def run(self, port, log):
    with util.temp_cd(self.src_dir):
      echo @(f"[server]\nbind = [\"tcp\", \"127.0.0.1:{port}\"]\nruntime = \"{self.threading}\"") > config.toml
      @(self.path / "target" / "release" / "epoxy-server") config.toml >@(log) &
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
      git clone "https://github.com/FoxMoss/WispServerCpp" @(self.git_repo) -b bleeding
    if not self.lib_repo.exists():
      git clone "https://github.com/uNetworking/uWebSockets" @(self.lib_repo) --recurse-submodules --shallow-submodules -b v20.64.0
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
      make all FlAGS=@(f"-Ofast -L{self.prefix / 'lib'} -I{self.prefix / 'include'} -march=native") -j@(core_count)
      
  def is_installed(self):
    return (self.git_repo / "wispserver").exists()
  
  def run(self, port, log):
    with util.temp_cd(self.git_repo):
      ./wispserver @(port) 2>&1 >@(log) &
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
  NodeWispServer(),
  JSWispServer(),
  PythonWispServer("python3"),
  RustWispServer("singlethread"),
  RustWispServer("multithread"),
  RustWispServer("multithreadalt"),
  CPPWispServer()
]

