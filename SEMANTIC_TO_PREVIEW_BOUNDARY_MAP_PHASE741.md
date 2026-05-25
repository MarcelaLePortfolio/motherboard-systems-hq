
# Semantic-To-Preview Boundary Map — Phase 741

Status: PLANNING-ONLY / READ-ONLY / NON-AUTHORITATIVE

## Purpose

Classify semantic inspection fields by whether they are safe to use for Preview/Diff planning, inspection display, comparison assertions, or future evidence review.

## Boundary Principle

Semantic data may support Preview/Diff understanding.

Semantic data must not control Preview rendering.

## Field Classifications

### Inspection-Only Fields

These fields may be reviewed by humans or diagnostic scripts but must not be consumed by live renderer logic:

- semantic_artifact_schema

- semantic_artifact_validated

- semantic_runtime_preservation_notes

- semantic_lifecycle_classification

- inspection_trace

- validation_trace

- sandbox_render_observations

- annotation_surface_notes

### Preview/Diff Planning Fields

These fields may inform future Preview/Diff planning documents:

- artifact_kind

- artifact_intent

- detected_sections

- comparison_targets

- expected_change_summary

- current_state_reference

- intended_state_reference

- ambiguity_flags

- safety_flags

### Renderer-Safe Display Candidates

These fields may be considered only for future read-only display beside Preview after separate approval:

- human_readable_summary

- inspection_status

- validation_status

- non_authoritative_warning

- comparison_label

- evidence_reference

### Disallowed Renderer Authority Fields

These fields must never be interpreted as commands:

- render_instruction

- mutation_instruction

- worker_instruction

- execution_instruction

- database_instruction

- filesystem_instruction

- orchestration_instruction

## Mandatory Rule

A semantic field may describe inspected meaning.

A semantic field may not decide renderer behavior.

## Future Approval Requirement

Any field promoted from planning evidence to renderer-adjacent display requires:

- explicit corridor approval

- read-only contract

- rollback path

- validation script

- no mutation authority

