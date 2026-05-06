# Backup Checkpoint: phase707-pre-context-injection

- Timestamp: 20260506_134459
- Branch: dev
- HEAD before commit: 63f2d60d
- External backup path: /Volumes/Rio Drive/Motherboard_Storage/snapshots/phase707-pre-context-injection-20260506_134459

## Disk
Filesystem        Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s5     228Gi   142Gi    52Gi    74%    699k  545M    0%   /System/Volumes/Data
map auto_home      0Bi     0Bi     0Bi   100%       0     0     -   /System/Volumes/Data/home
/dev/disk4s1     931Gi   144Gi   787Gi    16%       1     0  100%   /Volumes/Rio Drive

## Docker
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          3         3         21.22GB   21.22GB (100%)
Containers      3         3         32.77kB   0B (0%)
Local Volumes   2         2         40.52MB   0B (0%)
Build Cache     16        0         467.6MB   277MB

## Compose
NAME                                 IMAGE                              COMMAND                  SERVICE     CREATED          STATUS                 PORTS
motherboard_systems_hq-dashboard-1   motherboard_systems_hq-dashboard   "docker-entrypoint.s…"   dashboard   59 seconds ago   Up 57 seconds          0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
motherboard_systems_hq-postgres-1    postgres:16-alpine                 "docker-entrypoint.s…"   postgres    16 hours ago     Up 2 hours (healthy)   5432/tcp
motherboard_systems_hq-worker-1      motherboard_systems_hq-worker      "docker-entrypoint.s…"   worker      16 hours ago     Up 2 hours             

## Git status before checkpoint
?? PHASE707_PRE_CONTEXT_INJECTION_BACKUP.sh
?? checkpoints/phase707-pre-context-injection_20260506_134459.md
