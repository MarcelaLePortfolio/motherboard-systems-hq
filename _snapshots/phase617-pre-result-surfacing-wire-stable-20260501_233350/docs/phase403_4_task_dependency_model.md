# Phase 403.4 — Task Dependency Model

## Purpose

Define the deterministic structural model for task dependencies inside the execution substrate preparation corridor.

This phase remains **pre-execution**.

It defines only the structural dependency substrate that future governed execution may eventually rely on.

It does **not** introduce execution behavior.

---

## Boundary Classification

Phase 403.4 belongs to:

**Phase 403 — Execution substrate preparation corridor**

This phase defines:

- task dependency structure
- dependency graph shape
- structural validation requirements
- deterministic ordering guarantees
- readiness preconditions derived from structure

This phase does **not** define:

- task execution
- scheduling
- agent routing
- governance enforcement wiring
- operator approval wiring
- runtime mutation behavior

---

## Core Intent

A project may contain many tasks.

Tasks must be related through a deterministic dependency structure before execution can ever safely exist.

The system therefore requires a canonical model for:

- how one task depends on another
- how dependency edges are represented
- how dependency validity is checked
- how deterministic traversal order can be derived from structure alone

Dependency structure must be:

- explicit
- reproducible
- acyclic
- normalized
- validation-ready

---

## Canonical Dependency Object

Each dependency must be represented as a single explicit edge between two tasks.

### TaskDependency

| Field | Type | Meaning |
|---|---|---|
| `dependency_id` | string | Stable identifier for the dependency edge |
| `source_task_id` | string | Upstream prerequisite task |
| `target_task_id` | string | Downstream dependent task |
| `dependency_type` | enum | Structural dependency classification |
| `satisfaction_condition` | enum | Minimum structural condition required to consider the dependency satisfiable |
| `deterministic_order_index` | integer | Stable ordering field used for reproducible dependency normalization |

---

## Dependency Direction

Dependency direction is defined as:

- `source_task_id` = prerequisite task
- `target_task_id` = dependent task

Meaning:

`target_task_id` may not be considered structurally ready unless the dependency requirement referencing `source_task_id` is satisfied.

This is a structural statement only.

It does not introduce runtime readiness evaluation.

---

## Dependency Type Classification

Dependency types classify the structural reason one task depends on another.

### Allowed dependency types

#### `requires_completion`
Target depends on source task reaching completion.

#### `requires_success`
Target depends on source task reaching a successful outcome classification.

#### `requires_artifact`
Target depends on a required artifact produced by source task.

#### `requires_signal`
Target depends on a required signal emitted or packaged from source task.

#### `requires_operator_gate`
Target depends on a defined operator decision point associated with the source-side progression boundary.

---

## Satisfaction Condition Classification

The system must preserve explicit dependency satisfaction intent.

### Allowed satisfaction conditions

#### `completion`
Dependency expects structural completion state from source task.

#### `success`
Dependency expects structural success state from source task.

#### `artifact_present`
Dependency expects presence of a required artifact reference.

#### `signal_present`
Dependency expects presence of a required signal reference.

#### `operator_approved`
Dependency expects an operator approval boundary to have been satisfied.

---

## Dependency Graph Model

A project dependency graph is the full set of dependency edges across all declared tasks.

### DependencyGraph

A project dependency graph contains:

- declared tasks
- declared dependency edges
- normalized adjacency relationships
- validation results
- deterministic traversal ordering surface

The graph is a **structural substrate**, not an execution engine.

---

## Structural Invariants

The dependency model must satisfy all of the following invariants.

### 1. Referenced task existence invariant

Every `source_task_id` must reference an existing task in the project definition.

Every `target_task_id` must reference an existing task in the project definition.

No dependency may reference an undeclared task.

---

### 2. Self-reference rejection invariant

A dependency may not point from a task to itself.

Invalid:

- `source_task_id == target_task_id`

Self-referential dependency edges must be rejected.

---

### 3. Acyclic graph invariant

The dependency graph must be acyclic.

Cycles are forbidden.

This includes:

- direct two-task loops
- indirect multi-task loops
- longer structural cycles of any depth

If any cycle exists, project structure is invalid.

---

### 4. Canonical edge uniqueness invariant

The system must reject or normalize duplicate edges that express the same structural relationship.

Canonical uniqueness is determined by:

- `source_task_id`
- `target_task_id`
- `dependency_type`
- `satisfaction_condition`

Multiple identical edges must not produce structural ambiguity.

---

### 5. Deterministic ordering invariant

Dependency ordering must be reproducible for identical inputs.

For the same project structure, normalization must always produce the same ordering result.

Ordering must not depend on:

- insertion timing
- runtime process state
- container start order
- nondeterministic iteration behavior

---

### 6. Immutable normalized dependency invariant

Once a project has been structurally normalized, dependency edges must be treated as immutable for that normalized project version.

Any change to dependency structure requires re-normalization of the project structure.

---

### 7. Orphan target protection invariant

A task may exist without dependencies.

But no dependency edge may exist without both endpoints being valid.

This forbids orphaned dependency edges.

---

### 8. Missing prerequisite detectability invariant

If a target task references a dependency that cannot be structurally resolved, the system must be able to detect and classify that condition deterministically.

This remains a structural validation requirement only.

---

## Validation Classes

The dependency model must support the following structural validation classes.

### Referenced Task Validation

Checks:

- source task exists
- target task exists

Failure examples:

- missing source task
- missing target task
- both endpoints missing

---

### Self-Edge Validation

Checks:

- source and target are not identical

Failure example:

- task A depends on task A

---

### Duplicate Edge Validation

Checks:

- canonical duplicate edges do not coexist after normalization

Failure handling:

- either explicit rejection
- or deterministic normalization into one canonical edge

Whichever behavior is chosen later must remain fixed and deterministic.

---

### Cycle Validation

Checks:

- dependency graph is acyclic

Failure examples:

- A → B → A
- A → B → C → A

Cycle presence invalidates structural readiness.

---

### Ordering Validation

Checks:

- stable dependency ordering can be derived from canonical graph structure
- same structure yields same normalized order

---

## Deterministic Traversal Contract

This phase does **not** define actual execution traversal.

It defines only the precondition contract required so future traversal can exist safely.

Future traversal may only operate on a dependency graph that already satisfies:

- endpoint validity
- canonical uniqueness
- acyclic structure
- deterministic ordering

Traversal must therefore be **downstream of validation**, never upstream of it.

---

## Normalization Expectations

Normalization is not fully introduced in this phase, but the dependency model must be compatible with later normalization.

Normalization expectations include:

- stable edge identity
- stable ordering field usage
- duplicate handling discipline
- reproducible adjacency surface generation

This phase therefore establishes compatibility requirements for a later normalization corridor.

---

## Readiness Implications

The task dependency model contributes to project structural readiness.

A project cannot be considered structurally ready unless its dependency graph is:

- valid
- acyclic
- canonical
- reproducibly ordered

This is a **structure-only readiness statement**.

It does not imply execution readiness.

Execution readiness remains a later boundary.

---

## Explicit Exclusions

This phase does **not** introduce:

### No execution traversal
No task running behavior is defined.

### No scheduler
No sequencing engine is introduced.

### No runtime readiness engine
No dynamic eligibility engine is introduced.

### No agent integration
No agents consume this dependency graph.

### No governance enforcement wiring
Governance remains read-only and non-executing.

### No operator approval execution path
Operator gates may be structurally named, but not operationalized.

### No task state machine
Task state transitions are not defined here.

---

## Result of Phase 403.4

After Phase 403.4, the system should possess:

- a canonical task dependency object
- explicit dependency direction semantics
- approved dependency classifications
- approved satisfaction condition classifications
- dependency graph structural invariants
- validation classes for graph correctness
- deterministic ordering requirements for future normalization and traversal

This advances execution substrate definition without introducing execution itself.

---

## Safe Next Corridors

After the task dependency model, the next safe work remains structural.

Recommended next sequence:

### Phase 403.5 — Project validity verification model
Define project-level structural validity requirements across tasks, dependencies, and project definition consistency.

### Phase 403.6 — Structure normalization model
Define canonical normalization rules for project, task, and dependency structures.

### Phase 403.7 — Execution readiness boundary definition
Define the boundary between structurally valid substrate and future governed execution introduction.

---

## Completion Condition

Phase 403.4 is complete when:

- dependency edge structure is canonically defined
- allowed dependency classes are fixed
- structural invariants are explicitly declared
- validation classes are enumerated
- deterministic ordering guarantees are documented
- execution remains absent

