# Phase 487 — Artifact Containment Plan

## Objective
Eliminate the disk-exhaustion failure class by introducing hard boundaries on artifact generation before any cleanup mutation occurs.

## Scope
This corridor addresses:
- runaway logs
- runaway traces
- runaway scan outputs
- repo pollution from heavy runtime artifacts

This corridor does **not** change:
- backend logic
- governance logic
- approval logic
- execution logic

## Rules
1. Large runtime artifacts do not belong in the repo.
2. Controlled artifacts must be redirected to `/tmp/motherboard-systems-hq-artifacts` or another external runtime location.
3. Prefer overwrite (`>`) over append (`>>`).
4. Prefer sampled output over full dumps.
5. Any artifact-producing script must have a cap, rotation rule, or bounded sample size.
6. `docs/` remains allowed for small, bounded, human-readable outputs only.

## Deliverables
- `scripts/_safety/phase487_artifact_containment.sh`
- `scripts/_safety/artifact_safe_io.sh`
- `docs/phase487_artifact_containment_report.txt`

## First-pass success definition
- Repo has a containment scan/report
- External artifact root exists
- Safe I/O helper exists for follow-on script hardening
- No cleanup deletion occurs before evidence is captured

## Next step after this phase
Review the generated report and harden the specific scripts/processes that are producing uncontrolled artifacts.
