PHASE 456 — HARD RESTART DOCKER BACKEND PLAN

CLASSIFICATION:
CONTROLLED RUNTIME RECOVERY

OBJECTIVE

Perform one controlled hard restart of user-level Docker Desktop backend
processes after confirming:

• disk pressure is resolved
• repo is protected
• repeated soft-start attempts failed
• docker.sock is still never recreated

RATIONALE

Current evidence indicates Docker Desktop remained in a bad runtime state
after the original disk exhaustion event.

This step escalates from soft restart to hard restart of user-level
Docker processes only.

NON-GOALS

• No Docker factory reset
• No Docker prune
• No volume deletion
• No image deletion
• No compose mutation
• No application source mutation

SUCCESS CONDITION

• docker info succeeds
• docker compose up -d succeeds
• dashboard ports return
• dashboard becomes reachable again

FAILURE CONDITION

If docker.sock still does not appear after the hard restart,
the next corridor should be a Docker Desktop state repair decision,
not application mutation.

