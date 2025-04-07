from dataclasses import dataclass, field


@dataclass
class SchedulableTask:
    num_id: int = -1
    pred: list[int] = field(default_factory=list)
    duration: int = -1
    name: str = ""
    res_cpu: int = -1
    res_io: int = -1
    res_net: int = -1
    res_parallel: int = 1  # Immutable

    def to_dict(self) -> dict:
        return {
            "number": self.num_id,
            "pred": self.pred,
            "duration": self.duration,
            "name": self.name,
            "res_cpu": self.res_cpu,
            "res_io": self.res_io,
            "res_net": self.res_net,
        }

    def from_dict(self, d: dict):
        self.num_id = d["number"]
        self.pred = d["pred"]
        self.duration = d["duration"]
        self.name = d["name"]
        self.res_cpu = d["res_cpu"]
        self.res_io = d["res_io"]
        self.res_net = d["res_net"]
