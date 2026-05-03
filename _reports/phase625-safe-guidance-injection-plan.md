# Phase 625 SAFE GUIDANCE INJECTION PLAN

## Current State
- Dashboard widget restored (revert successful)
- Execution integrity preserved
- Guidance UI exists in React component only

## Root Issue Identified
Previous patch replaced large portions of dashboard-tasks-widget.js
Violation: NOT append-only

## Safe Strategy (MANDATORY)
1. DO NOT replace render()
2. DO NOT modify existing HTML structure
3. ONLY append inside existing task map template
4. ONLY add 1 helper: renderGuidance(t)

## Exact Injection Point
Inside state.tasks.map((t) => template)
AFTER existing task row

## Allowed Patch Shape
renderGuidance(t)

## Constraints
- No new state fields
- No fetch changes
- No polling changes
- No lifecycle changes

## Next Step
Prepare MICRO PATCH (diff-style, under 10 lines)
Zero overwrite risk
