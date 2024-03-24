#!/usr/bin/env xonsh

import util

server_dir = util.base_path / "server"

class WispServer:
  name = "generic wisp server"

  @classmethod
  def install(cls):
    pass

  @classmethod
  def is_installed(cls):
    pass

  @classmethod
  def run(cls, port):
    pass
  
  @classmethod
  def compat_check(cls):
    return True

class NodeWispServer(WispServer):
  name = "wisp-server-node"
  path = server_dir / "node"

  @classmethod
  def install(cls):
    mkdir -p @(cls.path)
    with util.temp_cd(cls.path):  
      npm i
  
  @classmethod
  def is_installed(cls):
    return (cls.path / "node_modules").exists()
  
  @classmethod
  def run(cls, port):
    with util.temp_cd(cls.path):  
      node server.js @(port) &
      return util.last_job()

implementations = [
  NodeWispServer
]