# Phase 42 PR Checklist — Read-Only + Preserve v41 Invariants

## Base
- [ ] Branch cut from: `v41.0-decision-correctness-gate-green`
- [ ] This PR contains **no runtime behavior changes** (docs/guards only unless explicitly stated)

## Read-Only Gate (Phase 42 default)
- [ ] No new write routes introduced (POST/PUT/PATCH/DELETE)
- [ ] No new mutations in workers / lease / reclaim / heartbeat paths
- [ ] No schema changes (unless explicitly promoted in a separate phase)

## Required Checks (must be green)
- [ ] `./scripts/phase42_scope_gate.sh` ✅
- [ ] `./scripts/phase42_readonly_guard.sh` ✅ (diff-based, code-only)
- [ ] `./scripts/phase41_invariants_gate.sh` ✅
- [ ] `./scripts/phase41_smoke.sh` ✅

## Evidence (paste outputs)
- `phase42_scope_gate`:
  - [ ] output pasted in PR
- `phase42_readonly_guard`:
  - [ ] output pasted in PR
- `phase41_invariants_gate` + `phase41_smoke`:
  - [ ] output pasted in PR

## Promotion Rule
If any write behavior is desired:
- [ ] Stop and open a **separate, explicitly-labeled promotion phase** with new invariants + acceptance.
