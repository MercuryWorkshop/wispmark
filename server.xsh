#!/usr/bin/env xonsh

import xonsh
import pathlib
import time

import util

server_dir = pathlib.Path(__file__).resolve().parent / "server"

class WispServer():
  name = "generic wisp server"

  def install(self):
    pass
  
  def run(self, port):
    pass
  
  def compat_check(self):
    return True

class NodeWispServer(WispServer):
  name = "wisp-server-node"
  path = server_dir / "node"

  def install(self):
    mkdir -p @(self.path)
    cd @(self.path)
    npm i
  
  def is_installed(self):
    return (self.path / "node_modules").exists()
  
  def run(self, port):
    node server.js @(port) &
    return util.get_last_job()
