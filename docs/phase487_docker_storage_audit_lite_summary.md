# Phase 487 Docker Storage Audit Summary (Lite)

Generated from `.runtime/docker_storage_audit_lite.txt`.

## Health Gate

- Docker storage inspection completed without the prior EOF failure.
- Safe to classify storage and plan controlled pruning rules.

## docker system df

```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          2         2         1.109GB   1.109GB (100%)
Containers      2         0         24.58kB   24.58kB (100%)
Local Volumes   1         1         40.67MB   0B (0%)
Build Cache     13        0         545.6MB   160MB
exit=0
```

## docker volume ls

```
DRIVER    VOLUME NAME
local     motherboard_systems_hq_pgdata
exit=0
```

## docker images

```
IMAGE                                     ID             DISK USAGE   CONTENT SIZE   EXTRA
motherboard_systems_hq-dashboard:latest   2e7fa2cb9599        393MB         69.6MB   U    
postgres:16-alpine                        93d55776e043        389MB          109MB   U    
exit=0
```

## docker ps -a --size

```
CONTAINER ID   IMAGE                              COMMAND                  CREATED      STATUS                            PORTS                    NAMES                                SIZE
e0c395f67ee9   motherboard_systems_hq-dashboard   "docker-entrypoint.s…"   2 days ago   Exited (255) About a minute ago   0.0.0.0:8080->3000/tcp   motherboard_systems_hq-dashboard-1   4.1kB (virtual 323MB)
2aeeb464669d   postgres:16-alpine                 "docker-entrypoint.s…"   2 days ago   Exited (255) About a minute ago   0.0.0.0:5432->5432/tcp   motherboard_systems_hq-postgres-1    20.5kB (virtual 280MB)
exit=0
```

