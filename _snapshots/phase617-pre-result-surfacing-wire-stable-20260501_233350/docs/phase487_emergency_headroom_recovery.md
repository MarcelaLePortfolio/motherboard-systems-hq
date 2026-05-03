# Phase 487 — Emergency Headroom Recovery

## Reason
The repository hit a second no-space condition before bounded producer-hunt hardening could be written.

## Immediate action
Removed the largest non-critical evidence dumps and transient runtime files from the working tree to restore write headroom.

## Files targeted
- oversized `docs/*.txt` evidence dumps
- root-level oversized phase dump
- transient `server.log`
- transient editor swap files

## Constraint compliance
No backend, governance, approval, or execution logic was changed.

## Next move
Once writable headroom is restored:
1. write the bounded producer-hunt script
2. redirect full hunt output to `/tmp/motherboard-systems-hq-artifacts`
3. keep only a compact summary in `docs/`
