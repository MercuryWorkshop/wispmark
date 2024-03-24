#!/usr/bin/env xonsh

import util

client_dir = util.base_path / "client"

class WispClient:
  name = "generic wisp client"

  @classmethod
  def install(cls):
    pass
  
  @classmethod
  def run(cls, server_port, target_port):
    pass
  
  @classmethod
  def is_installed(cls):
    pass

  @classmethod
  def compat_check(cls):
    return True

class NodeWispClient(WispClient):
  name = "wisp-client-js"
  path = client_dir / "node"

  @classmethod
  def install(cls):
    mkdir -p @(cls.path)
    with util.temp_cd(cls.path):
      npm i

  @classmethod
  def is_installed(cls):
    return (cls.path / "node_modules").exists()
  
  @classmethod
  def run(cls, server_port, target_port):
    with util.temp_cd(cls.path):
      node client.mjs @(server_port) @(target_port) &
      return util.last_job()

implementations = [
  NodeWispClient
]