SAFE CHANGE PROTOCOL — EXECUTION BOUNDARY RULES

This system operates under a controlled stability model.

────────────────────────────────────
1. CORE PRINCIPLE
────────────────────────────────────
No change is valid unless it improves at least one of:

- System stability
- System observability
- System recoverability

If it does not, it is considered scope creep and must be rejected.

────────────────────────────────────
2. PROHIBITED BEHAVIOR
────────────────────────────────────
The following are explicitly disallowed unless correcting a critical bug:

- Adding new execution modes
- Expanding retry intelligence logic
- Introducing new orchestration layers
- Creating parallel pipelines for the same function
- Modifying snapshot/restore mechanics without necessity
- Adding “enhancement” features without a failure-driven reason

────────────────────────────────────
3. REQUIRED CHANGE DISCIPLINE
────────────────────────────────────

Every change must declare:

A. Why this change exists
   - What is broken or insufficient today?

B. What risk it introduces
   - What new instability could this create?

C. Why it does not violate system boundaries
   - Does it preserve deterministic recovery?

────────────────────────────────────
4. SNAPSHOT RULE
────────────────────────────────────

If a change cannot be safely reverted via:

- git tag
- snapshot restore script
- or deterministic rollback

→ It must NOT be deployed.

────────────────────────────────────
5. RECOVERY GUARANTEE RULE
────────────────────────────────────

Every state must be:

- Rebuildable
- Restorable
- Reproducible

If any of these fail, the system is considered unstable.

────────────────────────────────────
6. OPERATIONAL MODE

Default system mode:
- Stability-first
- Not feature expansion

────────────────────────────────────
END OF PROTOCOL
