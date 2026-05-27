
# Decision Snapshot — Clara (Roadmap Strategist)

**Decision:** Adopt **Clara — Roadmap Strategist** as the planning/mapping specialist.

## Why it fits

* Clear strategic tone; calm authority.
* Distinct from **Matilda** (delegation) and **Cade/Effie** (execution).
* Brand-aligned, retro-modern, professional.

## What changed today

* Identity docs added:

  * `docs/agents/clara_profile.json`
  * `docs/agents/CLARA_README.md`
* No runtime or process changes were made.

## Near-term integration (when you’re ready)

* Matilda triggers planning → Clara proposes:

  * `plan.json` (initiatives → workstreams → tasks → dependencies → milestones)
  * `risk_notes.json`
  * Tracker partials (HTML/JSON) for dashboard lanes
* Matilda approves → Cade writes partials → Dashboard updates.
* Optional later: periodic replan loop, milestone reminders, drift detection.

## Safety & compliance

* Clara proposes only; Matilda approves before any system mutation.
* Keep Clara behind Matilda’s compliance wrapper for public builds.

## Labels

* Status row: **Clara — Roadmap Strategist** (short: **Clara (RS)**).
* Ops ticker examples:

  * `Clara (RS): Proposed plan.json for "Tracker Stabilization"`
  * `Clara (RS): Flagged dependency WS-UI-01 → T-ARIA-01`
  * `Clara (RS): Re-baselined critical path (Δ −0.5d)`

