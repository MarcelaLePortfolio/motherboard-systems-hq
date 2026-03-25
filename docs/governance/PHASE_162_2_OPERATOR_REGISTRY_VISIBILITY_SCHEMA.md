PHASE 162.2 — OPERATOR REGISTRY VISIBILITY SCHEMA

STATUS: CONTRACT SCHEMA
TYPE: READ-ONLY EXPOSURE MAP
PURPOSE: DEFINE EXACT SAFE FIELDS FOR OPERATOR REGISTRY INSPECTION

────────────────────────────────

PURPOSE

Phase 162.2 defines the exact registry fields that may be exposed
to operators through inspection helpers without introducing any
mutation, execution, or authority expansion.

This converts the Phase 162.1 policy into a concrete visibility schema.

────────────────────────────────

VISIBILITY CLASSIFICATIONS

All registry fields must fall into one of four categories:

CLASS A — SAFE (fully visible)
CLASS B — SUMMARY (derived only)
CLASS C — REDACTED (partial visibility)
CLASS D — PROHIBITED (never visible)

────────────────────────────────

CLASS A — SAFE FIELDS

These fields may be exposed directly:

registry_component_name
registry_component_type
registry_owner
registry_version
registry_status
capability_name
capability_category
capability_presence (boolean only)
governance_policy_name
governance_policy_status
task_state_types
terminal_state_types
signal_types
reducer_names
validation_pass_fail
integrity_status
health_status
coverage_status
registration_timestamp (no internal IDs)

Reason:
Structural metadata only.
No execution value.

────────────────────────────────

CLASS B — SUMMARY FIELDS

These must only be exposed as derived values:

capability_count
policy_count
registry_component_count
active_task_count
failed_task_count
signal_volume_counts
integrity_violation_counts
validation_warning_counts

Allowed exposure format:

counts
aggregates
status summaries
percentages

Never raw internal datasets.

────────────────────────────────

CLASS C — REDACTED FIELDS

These fields may only appear in masked form:

worker_identifiers → hashed
container_ids → truncated
filesystem_paths → partial
repo_paths → partial
policy_ids → hashed
task_ids → truncated
run_ids → truncated

Example:

task_id: task_7f3a****
container: dash****
worker: wrk_92b***

Purpose:
Allow traceability without exposure.

────────────────────────────────

CLASS D — PROHIBITED FIELDS

These must NEVER be exposed:

environment variables
secrets
tokens
credentials
auth headers
execution commands
shell arguments
docker arguments
git mutation commands
filesystem mutation commands
worker runtime configs
policy enforcement keys
private routing maps
internal registry mutation hooks

These must always be filtered before exposure.

────────────────────────────────

VISIBILITY FILTER RULE

All operator registry helpers must apply:

ALLOW LIST filtering (never deny list).

Only explicitly approved fields may pass.

Default rule:

IF NOT APPROVED → DO NOT EXPOSE.

────────────────────────────────

EXPOSURE STRUCTURE

All operator registry inspection must return:

STRUCTURE
STATUS
CLASSIFICATION
COUNTS
VALIDATION RESULTS

Never raw execution data.

Example safe structure:

component:
type:
owner:
status:
capabilities:
count:
health:
integrity:

Never:

commands
paths
arguments
runtime execution data

────────────────────────────────

SCHEMA ENFORCEMENT RULES

Operator registry helpers must enforce:

Field filtering before exposure
Redaction before formatting
Summary conversion before display
Deterministic ordering
Snapshot based reads only

Never:

direct registry reads to UI
live mutation views
execution surface linking

────────────────────────────────

DETERMINISM RULE

Registry inspection must always be:

Snapshot based
Non-streaming
Replay safe
Side-effect free

No live mutation reflections allowed.

────────────────────────────────

PHASE RESULT

Phase 162.2 establishes:

Field-level registry exposure contract
Safe visibility classification model
Redaction standards
Operator inspection schema
Future tooling exposure guardrails

This phase introduces:

ZERO execution changes
ZERO registry changes
ZERO UI changes
ZERO authority changes

────────────────────────────────

NEXT PHASE

Phase 162.3 — Operator Registry Inspection Adapter

Purpose:

Create deterministic adapter layer translating
internal registry → operator safe schema.

This will remain read-only.

