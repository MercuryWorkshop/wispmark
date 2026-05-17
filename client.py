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
        return [self.run_once(*args, **kwargs) for _ in range(self.instances)]


class NodeWispClient(BaseWispClient):
    name = "wisp-js"
    path = client_dir / "js"

    def install(self):
        self.path.mkdir(parents=True, exist_ok=True)
        util.run(["npm", "i"], cwd=self.path)

    def is_installed(self):
        return (self.path / "node_modules").exists()

    def run_once(self, server_port, target_port, log):
        return util.run_bg(
            ["node", "client.mjs", str(server_port), str(target_port), str(self.streams)],
            log_path=log,
            cwd=self.path,
        )


class RustWispClient(BaseWispClient):
    name = "wisp-mux"
    path = client_dir / "rust"

    def __init__(self, streams, instances=1):
        super().__init__(streams, instances)
        self.src_dir = self.path / "simple-wisp-client"

    def install(self):
        if not self.path.exists():
            util.run(["git", "clone",
                      "https://github.com/MercuryWorkshop/epoxy-tls",
                      self.path])
        util.run(["cargo", "b", "-r"], cwd=self.src_dir)

    def is_installed(self):
        binary = "simple-wisp-client.exe" if util.IS_WINDOWS else "simple-wisp-client"
        return (self.path / "target" / "release" / binary).exists()

    def run_once(self, server_port, target_port, log):
        binary = "simple-wisp-client.exe" if util.IS_WINDOWS else "simple-wisp-client"
        return util.run_bg(
            [
                self.path / "target" / "release" / binary,
                "-w", f"ws://127.0.0.1:{server_port}/",
                "-t", f"127.0.0.1:{target_port}",
                "-s", str(self.streams),
                "-p", "50",
            ],
            log_path=log,
            cwd=self.src_dir,
        )


implementations = [
    NodeWispClient(10),
    NodeWispClient(10, 5),
    RustWispClient(10),
    RustWispClient(10, 5),
]
