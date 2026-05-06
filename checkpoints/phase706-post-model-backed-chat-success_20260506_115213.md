# Backup Checkpoint: phase706-post-model-backed-chat-success

- Timestamp: 20260506_115213
- Branch: dev
- HEAD before commit: 134803be
- External backup path: /Volumes/Rio Drive/Motherboard_Storage/snapshots/phase706-post-model-backed-chat-success-20260506_115213

## Disk
Filesystem        Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s5     228Gi   142Gi    52Gi    74%    698k  546M    0%   /System/Volumes/Data
map auto_home      0Bi     0Bi     0Bi   100%       0     0     -   /System/Volumes/Data/home
/dev/disk4s1     931Gi   144Gi   788Gi    16%       1     0  100%   /Volumes/Rio Drive

## Docker
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          3         3         21.02GB   21.02GB (100%)
Containers      3         3         32.77kB   0B (0%)
Local Volumes   2         2         40.5MB    0B (0%)
Build Cache     12        0         241.5MB   50.92MB

## Compose
NAME                                 IMAGE                              COMMAND                  SERVICE     CREATED         STATUS                    PORTS
motherboard_systems_hq-dashboard-1   motherboard_systems_hq-dashboard   "docker-entrypoint.s…"   dashboard   2 minutes ago   Up 2 minutes              0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
motherboard_systems_hq-postgres-1    postgres:16-alpine                 "docker-entrypoint.s…"   postgres    15 hours ago    Up 35 minutes (healthy)   5432/tcp
motherboard_systems_hq-worker-1      motherboard_systems_hq-worker      "docker-entrypoint.s…"   worker      14 hours ago    Up 35 minutes             

## Git status before checkpoint
?? checkpoints/phase706-post-model-backed-chat-success_20260506_115213.md
