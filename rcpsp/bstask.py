class BSTask(dict):
    def __init__(self, *args, **kwargs):
        self['start_time'] = None
        self['elapsed_time'] = None
        self['status'] = None
        self['iostat'] = {}
        self['rusage'] = {}
        self['child_rusage'] = {}
        self['name'] = None
        super(BSTask, self).__init__(*args, **kwargs)

    @property
    def cputime(self):
        """Sum of user and system time taken by the task"""
        rusage = self['rusage']['ru_stime'] + self['rusage']['ru_utime']
        if self['child_rusage']:
            # Child rusage may have been optimized out
            return rusage + self['child_rusage']['ru_stime'] + self['child_rusage']['ru_utime']
        else:
            return rusage

    @property
    def walltime(self):
        """Elapsed wall clock time"""
        return self['elapsed_time']

    @property
    def read_bytes(self):
        """Bytes read from the block layer"""
        return self['iostat']['read_bytes']

    @property
    def write_bytes(self):
        """Bytes written to the block layer"""
        return self['iostat']['write_bytes']

    @property
    def read_ops(self):
        """Number of read operations on the block layer"""
        if self['child_rusage']:
            # Child rusage may have been optimized out
            return self['rusage']['ru_inblock'] + self['child_rusage']['ru_inblock']
        else:
            return self['rusage']['ru_inblock']

    @property
    def write_ops(self):
        """Number of write operations on the block layer"""
        if self['child_rusage']:
            # Child rusage may have been optimized out
            return self['rusage']['ru_oublock'] + self['child_rusage']['ru_oublock']
        else:
            return self['rusage']['ru_oublock']

    @classmethod
    def from_file(cls, buildstat_file, fallback_end=0):
        """Read buildstat text file. fallback_end is an optional end time for tasks that are not recorded as finishing."""
        bs_task = cls()
        end_time = None
        with open(buildstat_file) as fobj:
            for line in fobj.readlines():
                key, val = line.split(':', 1)
                val = val.strip()
                if val.startswith("do_"):
                    bs_task["name"] = f"{key}.{val}"
                elif key == 'Started':
                    start_time = float(val)
                    bs_task['start_time'] = start_time
                elif key == 'Ended':
                    end_time = float(val)
                elif key.startswith('IO '):
                    split = key.split()
                    bs_task['iostat'][split[1]] = int(val)
                elif key.find('rusage') >= 0:
                    split = key.split()
                    ru_key = split[-1]
                    if ru_key in ('ru_stime', 'ru_utime'):
                        val = float(val)
                    else:
                        val = int(val)
                    ru_type = 'rusage' if split[0] == 'rusage' else \
                                                      'child_rusage'
                    bs_task[ru_type][ru_key] = val
                elif key == 'Status':
                    bs_task['status'] = val
        # If the task didn't finish, fill in the fallback end time if specified
        if start_time and not end_time and fallback_end:
            end_time = fallback_end
        if start_time and end_time:
            bs_task['elapsed_time'] = end_time - start_time
        else:
            raise ValueError(f"{buildstat_file} looks like a invalid buildstats file")
        return bs_task

    @property
    def name(self) -> float:
        return self["name"]

    @property
    def proc_time(self) -> float:
        if self["elapsed_time"] == 0:
            return 0
        return self.cputime / self["elapsed_time"]

    @property
    def io_bytes(self) -> float:
        if self["elapsed_time"] == 0:
            return 0
        ret = (self.read_bytes + self.write_bytes) / self["elapsed_time"]
        if self["elapsed_time"] < 5:
            ret = 10 * 2 ** 20
        return ret

    @property
    def iops(self) -> float:
        if self["elapsed_time"] == 0:
            return 0
        ret = (self.read_ops + self.write_ops) / self["elapsed_time"]
        # if ret > 3000:
        #     ret = 1000
        # if self["elapsed_time"] < 15:
        #     ret = 1000
        return ret

    @property
    def net_bytes(self) -> float:
        if self["elapsed_time"] == 0 or self.name.find("do_fetch") == -1:
            return 0
        ret = (self["iostat"]["rchar"] + self["iostat"]["wchar"] - self.read_bytes - self.write_bytes - self["iostat"]["cancelled_write_bytes"]) / self["elapsed_time"]
        if self["elapsed_time"] < 10:
            ret = 10 * 2 ** 20
        return ret
