# Phase 665 — Guidance History UI Enhancement Plan

Status: DESIGN ONLY

Goal:
Improve readability of guidance history without introducing mutations or new backend dependencies.

Enhancements:
- Show latest snapshot timestamp in human-readable format (HH:MM:SS)
- Show preview of latest guidance message (first 1–2 lines)
- Keep count of total snapshots
- Maintain lightweight, secondary visual hierarchy

Constraints:
- Read-only UI
- No execution/worker/scheduler/DB changes
- Continue using /api/guidance-history only

Next safe action:
- Extend existing refreshGuidanceHistory() to format timestamp and preview text
