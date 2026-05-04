# Phase 672 — Next Focus: Guidance UX Refinement

Status: READY

Context:
- Backend guidance signals are stable and validated.
- UI is connected and rendering correctly.
- End-to-end loop is complete.

Next objective:
Make the guidance feel *operator-grade*, not just technically correct.

Focus Areas:

1. Visual Priority Amplification
- Increase contrast between CRITICAL / WARNING / INFO
- Make CRITICAL impossible to miss (background tint or badge)

2. Signal Density Control
- Prevent spam if many tasks exist
- Consider:
  - deduping similar messages
  - collapsing repeated signals into counts

3. Action Clarity
- Improve "suggested_action" visibility
- Consider:
  - icon or prefix (e.g. ⚡ Action:)
  - stronger styling than normal text

4. Temporal Context
- Show relative time:
  - "just now"
  - "5s ago"
- Helps operator trust freshness

5. Empty State Upgrade
- Replace:
  "No active guidance"
- With:
  Calm but intentional message:
  "All systems operating normally"

Strict Constraints:
- Still NO backend mutation
- NO contract changes
- Pure UI refinement only

Goal:
Transform guidance from “visible” → “instantly actionable”
