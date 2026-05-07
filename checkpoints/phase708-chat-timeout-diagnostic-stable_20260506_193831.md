# Backup Checkpoint: phase708-chat-timeout-diagnostic-stable

- Timestamp: 20260506_193831
- Branch: dev
- HEAD before commit: 13112cf2
- External backup path: /Volumes/Rio Drive/Motherboard_Storage/snapshots/phase708-chat-timeout-diagnostic-stable-20260506_193831

## Disk
Filesystem        Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s5     228Gi   143Gi    51Gi    74%    709k  537M    0%   /System/Volumes/Data
map auto_home      0Bi     0Bi     0Bi   100%       0     0     -   /System/Volumes/Data/home
/dev/disk4s1     931Gi   144Gi   787Gi    16%       1     0  100%   /Volumes/Rio Drive

## Docker
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          3         3         21.27GB   21.27GB (100%)
Containers      3         3         32.77kB   0B (0%)
Local Volumes   2         2         40.55MB   0B (0%)
Build Cache     17        0         524.2MB   333.6MB

## Compose
NAME                                 IMAGE                              COMMAND                  SERVICE     CREATED        STATUS                 PORTS
motherboard_systems_hq-dashboard-1   motherboard_systems_hq-dashboard   "docker-entrypoint.s…"   dashboard   6 hours ago    Up 6 hours             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
motherboard_systems_hq-postgres-1    postgres:16-alpine                 "docker-entrypoint.s…"   postgres    22 hours ago   Up 8 hours (healthy)   5432/tcp
motherboard_systems_hq-worker-1      motherboard_systems_hq-worker      "docker-entrypoint.s…"   worker      21 hours ago   Up 8 hours             

## Git status before checkpoint
?? PHASE708_CHAT_TIMEOUT_DIAGNOSTIC_BACKUP.sh
?? checkpoints/phase708-chat-timeout-diagnostic-stable_20260506_193831.md
