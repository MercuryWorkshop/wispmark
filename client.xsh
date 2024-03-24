#!/usr/bin/env xonsh

import util

client_dir = util.base_path / "client"

class NodeWispClient:
  name = "wisp-client-js"
  path = client_dir / "node"

  def install(self):
    mkdir -p @(self.path)
    with util.temp_cd(self.path):
      npm i

  def is_installed(self):
    return (self.path / "node_modules").exists()
  
  def run(self, server_port, target_port):
    with util.temp_cd(self.path):
      node client.mjs @(server_port) @(target_port) &
      return util.last_job()


class RustWispClient:
  name = "wisp-mux"
  path = client_dir / "rust"

  def install(self):
    with util.temp_cd(self.path):
      cargo build --release

  def is_installed(self):
    return (self.path / "Cargo.lock").exists()
  
  def run(self, server_port, target_port):
    with util.temp_cd(self.path):
      cargo r -r 127.0.0.1 @(server_port) / 127.0.0.1 @(target_port) false 2>&1 >/dev/null &
      return util.last_job()

implementations = [
  NodeWispClient(),
  RustWispClient()
]