# Phase 43 PR Checklist — Read-Only + Preserve Phase 41 Invariants

## Base
- [ ] Branch cut from: `v42.0-readonly-preserve-v41-gate-green`
- [ ] PR is read-only by default (promotion required for any writes)

## Read-Only Gate (Phase 43 default)
- [ ] No new write routes introduced (POST/PUT/PATCH/DELETE)
- [ ] No new mutations in workers / lease / reclaim / heartbeat paths
- [ ] No schema changes (unless explicitly promoted in a separate phase)

## Required Checks (must be green)
- [ ] `./scripts/phase43_scope_gate.sh` ✅
- [ ] `./scripts/phase42_readonly_guard.sh` ✅ (diff-based, code-only vs v41)
- [ ] `./scripts/phase41_invariants_gate.sh` ✅
- [ ] `./scripts/phase41_smoke.sh` ✅

## Evidence (paste outputs)
- `phase43_scope_gate`:
  - [ ] output pasted in PR
- `phase42_readonly_guard`:
  - [ ] output pasted in PR
- `phase41_invariants_gate` + `phase41_smoke`:
  - [ ] output pasted in PR

## Promotion Rule
If any write behavior is desired:
- [ ] Stop and open a **separate, explicitly-labeled promotion phase** with new invariants + acceptance.
