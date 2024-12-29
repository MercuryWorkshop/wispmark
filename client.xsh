#!/usr/bin/env xonsh

import util

client_dir = util.base_path / "client"

class NodeWispClient:
  name = "wisp-js"
  path = client_dir / "js"

  def __init__(self, streams):
    self.streams = streams
    self.name = f"{self.name} ({streams})"

  def install(self):
    mkdir -p @(self.path)
    with util.temp_cd(self.path):
      npm i

  def is_installed(self):
    return (self.path / "node_modules").exists()
  
  def run(self, server_port, target_port, log):
    with util.temp_cd(self.path):
      node client.mjs @(server_port) @(target_port) @(self.streams) 2>&1 >@(log) &
      return util.last_job()


class RustWispClient:
  name = "wisp-mux"
  path = client_dir / "rust"
  src_dir = path / "simple-wisp-client"

  def __init__(self, streams):
    self.streams = streams
    self.name = f"{self.name} ({streams})"

  def install(self):
    if not self.path.exists():
      git clone "https://github.com/MercuryWorkshop/epoxy-tls" @(self.path)
    with util.temp_cd(self.src_dir):
      cargo b -r

  def is_installed(self):
    return (self.path / "target" / "release" / "simple-wisp-client").exists()
  
  def run(self, server_port, target_port, log):
    with util.temp_cd(self.src_dir):
      @(self.path / "target" / "release" / "simple-wisp-client") -w ws://127.0.0.1:@(server_port)/ -t 127.0.0.1:@(target_port) -s @(self.streams) -p 50 2>&1 >@(log) &
      return util.last_job()

class CrystalWispClient:
  name = "wisp-client-crystal"
  path = client_dir / "crystal"
  src_path = path / "git"

  def __init__(self, streams):
    self.streams = streams
    self.name = f"{self.name} ({streams})"

  def install(self):
    if not self.src_path.exists():
      git clone "https://github.com/Astatine-Development/wisp-client-crystal" @(self.src_path)
    with util.temp_cd(self.path):
      crystal build demo.cr --release --no-debug --progress -o demo

  def is_installed(self):
    return (self.path / "demo").exists()
  
  def run(self, server_port, target_port, log):
    with util.temp_cd(self.path):
      @(self.path / "demo") @(server_port) @(target_port) @(self.streams) 2>&1 >@(log) &
      return util.last_job()

implementations = [
  NodeWispClient(1),
  NodeWispClient(10),
  RustWispClient(1),
  RustWispClient(10),
  CrystalWispClient(1),
  CrystalWispClient(10),
]
