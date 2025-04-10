# Fixing Disk Bandwidth Reporting for NVMe

When collecting info from `proc/diskstats` in `buildstats.py`, NVMe SSD devices were not being handled.  
To fix this, apply the patch `add_nvme_support.patch` to the file `meta/lib/buildstats.py`.
