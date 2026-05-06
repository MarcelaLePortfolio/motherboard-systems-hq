# Backup Checkpoint: phase706-pre-matilda-model-architecture

- Timestamp: 20260506_114016
- Branch: dev
- HEAD before commit: 98253b46
- External backup path: /Volumes/Rio Drive/Motherboard_Storage/snapshots/phase706-pre-matilda-model-architecture-20260506_114016

## Disk
Filesystem        Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s5     228Gi   160Gi    34Gi    83%    698k  354M    0%   /System/Volumes/Data
map auto_home      0Bi     0Bi     0Bi   100%       0     0     -   /System/Volumes/Data/home
/dev/disk4s1     931Gi   144Gi   788Gi    16%       1     0  100%   /Volumes/Rio Drive

## Docker
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          3         3         40.76GB   40.76GB (100%)
Containers      3         3         32.77kB   0B (0%)
Local Volumes   2         2         40.5MB    0B (0%)
Build Cache     0         0         0B        0B

## Compose
NAME                                 IMAGE                              COMMAND                  SERVICE     CREATED        STATUS                    PORTS
motherboard_systems_hq-dashboard-1   motherboard_systems_hq-dashboard   "docker-entrypoint.s…"   dashboard   2 hours ago    Up 23 minutes             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
motherboard_systems_hq-postgres-1    postgres:16-alpine                 "docker-entrypoint.s…"   postgres    14 hours ago   Up 24 minutes (healthy)   5432/tcp
motherboard_systems_hq-worker-1      motherboard_systems_hq-worker      "docker-entrypoint.s…"   worker      14 hours ago   Up 23 minutes             

## Git status before checkpoint
?? PHASE706_CONTEXTUAL_ADVISORY_PATCH.sh
?? checkpoints/phase706-pre-matilda-model-architecture_20260506_114016.md
