#!/usr/bin/env xonsh

import util

client_dir = util.base_path / "client"

class BaseWispClient:
  def __init__(self, streams, instances=1):
    self.streams = streams
    self.instances = instances
    if instances == 1:
      self.name = f"{self.name} ({streams})"
    else:
      self.name = f"{self.name} ({instances}x{streams})"
  
  def run(self, *args, **kwargs):
    jobs = []
    for i in range(self.instances):
      jobs.append(self.run_once(*args, **kwargs))
    return jobs

class NodeWispClient(BaseWispClient):
  name = "wisp-js"
  path = client_dir / "js"

  def install(self):
    mkdir -p @(self.path)
    with util.temp_cd(self.path):
      npm i

  def is_installed(self):
    return (self.path / "node_modules").exists()
  
  def run_once(self, server_port, target_port, log):
    with util.temp_cd(self.path):
      node client.mjs @(server_port) @(target_port) @(self.streams) 2>&1 >@(log) &
      return util.last_job()

class RustWispClient(BaseWispClient):
  name = "wisp-mux"
  path = client_dir / "rust"
  src_dir = path / "simple-wisp-client"

  def install(self):
    if not self.path.exists():
      git clone "https://github.com/MercuryWorkshop/epoxy-tls" @(self.path)
    with util.temp_cd(self.src_dir):
      cargo b -r

  def is_installed(self):
    return (self.path / "target" / "release" / "simple-wisp-client").exists()
  
  def run_once(self, server_port, target_port, log):
    with util.temp_cd(self.src_dir):
      @(self.path / "target" / "release" / "simple-wisp-client") -w ws://127.0.0.1:@(server_port)/ -t 127.0.0.1:@(target_port) -s @(self.streams) -p 50 2>&1 >@(log) &
      return util.last_job()

implementations = [
  NodeWispClient(1),
  NodeWispClient(10),
  NodeWispClient(10, 5),
  RustWispClient(1),
  RustWispClient(10),
  RustWispClient(10, 5)
]
