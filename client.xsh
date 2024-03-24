#!/usr/bin/env xonsh

import util

client_dir = util.base_path / "client"

class NodeWispClient:
  name = "wisp-client-js"
  path = client_dir / "node"

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

  def __init__(self, streams):
    self.streams = streams
    self.name = f"{self.name} ({streams})"

  def install(self):
    with util.temp_cd(self.path):
      cargo build --release

  def is_installed(self):
    return (self.path / "Cargo.lock").exists()
  
  def run(self, server_port, target_port, log):
    with util.temp_cd(self.path):
      cargo r -r 127.0.0.1 @(server_port) / 127.0.0.1 @(target_port) false @(self.streams) 2>&1 >@(log) &
      return util.last_job()

implementations = [
  NodeWispClient(1),
  NodeWispClient(10),
  RustWispClient(1),
  RustWispClient(10)
]