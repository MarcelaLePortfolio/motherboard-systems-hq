PHASE 456 — DOCKER DAEMON RESTART PLAN

CLASSIFICATION:
MINIMAL RUNTIME RESTORATION

OBJECTIVE

Restore Docker daemon availability after disk-pressure recovery,
then restart the existing dashboard stack without changing source,
compose definitions, images, or volumes.

EVIDENCE BASIS

Latest root-cause check confirmed:

• Disk pressure is resolved
• Docker Desktop processes exist
• Docker daemon socket is absent
• No dashboard listener exists on 8080 or 3000
• docker-compose.yml exists
• Failure is daemon availability, not proven app crash

RECOVERY METHOD

1. Cleanly stop Docker Desktop processes
2. Remove only stale runtime sockets/pipes under ~/.docker/run
3. Relaunch Docker Desktop
4. Wait for docker info to succeed
5. Start existing compose stack only
6. Verify ports and HTTP
7. Inspect logs if startup fails

NON-GOALS

• No Docker reset
• No Docker prune
• No volume deletion
• No image deletion
• No source mutation
• No compose mutation

