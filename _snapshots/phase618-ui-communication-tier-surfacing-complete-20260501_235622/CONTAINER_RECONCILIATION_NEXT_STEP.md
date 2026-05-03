# Container Reconciliation — Next Safe Step

Date: 2026-03-20

## Decision
Do not containerize anything new.

Container assets already exist, and the audit shows the stack has multiple container-era entrypoints, overrides, helper scripts, and historical restore paths.

## Most Important Finding
The current compose path references `Dockerfile.dashboard`, while the earlier protection audit inspected `Dockerfile`.

That means the immediate risk is not "missing containerization."
The immediate risk is "editing the wrong container authority file."

## Next Safe Bounded Task
Identify the authoritative active container files for the current dashboard lane.

## Bounded Questions To Resolve
1. Which Dockerfile is actually used by the active compose path?
2. Which compose files are active for the normal dashboard lane?
3. Are there worker compose lanes that must remain separate from the dashboard lane?
4. Are there mismatches between current runtime scripts and compose declarations?
5. Which files are historical overlays versus current authorities?

## Rule
No runtime topology edits until the authority-file map is captured.

## Expected Output
A single reconciliation snapshot that names:
- active dashboard Dockerfile
- active compose base
- active worker compose path(s)
- override files still in play
- safe next modification target
