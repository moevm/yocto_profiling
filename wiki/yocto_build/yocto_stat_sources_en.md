# How Yocto Collects Statistics

### Source of Information

Yocto collects CPU, IO, and memory pressure from:
- `/proc/pressure/cpu`
- `/proc/pressure/io`
- `/proc/pressure/memory`

Per-process info is taken from:
- `/proc/<pid>/stat`
- `/proc/<pid>/io`

### Frequency of Updates

Statistics update roughly once per second  
(set via variable `psi_accumulation_interval = 1.0`)

### Impact on Build Time

To evaluate the performance overhead, two builds were compared:

- `core-image-minimal` **with stats collection**: 173m 10.807s  
- `core-image-minimal` **without stats collection**: 167m 47.974s

So, enabling statistics increases build time by ≈ **3%**.
