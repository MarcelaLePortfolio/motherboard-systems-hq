PHASE 152A — RUNTIME STORE ATTACHMENT DESIGN

STATUS: DESIGN COMPLETE
DATE: 2026-03-24

────────────────────────────────

PHASE PURPOSE

Define how RegistryStateStore attaches to real runtime context
without introducing duplicate registry state or mutation risk.

This phase is design only.

No runtime wiring occurs here.

────────────────────────────────

CORE DESIGN RULE

There must only ever be ONE registry state instance.

RegistryStateStore becomes:

The canonical runtime registry container.

No alternate stores allowed.
No shadow stores allowed.
No in-memory duplicates allowed.

All registry reads and mutations must target the same instance.

────────────────────────────────

CURRENT STATE (PRE-RUNTIME)

Current design:

RegistryStateStore is created locally by scripts and test surfaces.

This was correct for Phase 151 isolation.

Runtime integration now requires controlled ownership.

────────────────────────────────

RUNTIME ATTACHMENT MODEL

Target model:

RegistryStateStore becomes a runtime-owned singleton.

Example structure:

RuntimeContainer
  → RegistryStateStore (single instance)
  → RegistryOwner
  → RegistryMutationCoordinator
  → RegistryReadSurface
  → RegistryDiagnostics
  → RegistrySummary
  → RegistryInspection

No component instantiates its own RegistryStateStore.

All receive injected reference.

────────────────────────────────

ATTACHMENT METHOD

Design decision:

Dependency Injection only.

Never allow:

new RegistryStateStore() inside random components.

Instead:

Runtime container creates store once.

Store is passed into:

RegistryOwner
RegistryMutationCoordinator
RegistryReadSurface
RegistryVisibilityDiagnostics
RegistrySummarySurface
RegistryOperatorInspection

────────────────────────────────

OWNERSHIP MODEL

Runtime container owns store lifecycle.

RegistryOwner does NOT own store.

Coordinator does NOT own store.

Read surfaces do NOT own store.

Only container manages lifecycle.

────────────────────────────────

STATE CONSISTENCY GUARANTEE

To prevent drift:

All registry access must occur through:

RegistryOwner (mutation)
RegistryReadSurface (reads)

No direct stateStore access allowed from external modules.

RegistryStateStore should remain internal infrastructure.

────────────────────────────────

RUNTIME SAFETY REQUIREMENTS

Runtime attachment must guarantee:

Single instance store
No duplicate construction
No store swapping
No hot replacement
No uncontrolled state injection

Future phases may introduce:

Store persistence
Store recovery
Store serialization

But NOT in this phase.

────────────────────────────────

IMPLEMENTATION CONSTRAINTS (FUTURE)

When wiring runtime:

RegistryStateStore must be created:

Inside runtime container bootstrap.

Example (future):

runtime/registry_runtime_container.ts

Container creates:

const registryStore = new RegistryStateStore()

Then injects into all surfaces.

────────────────────────────────

SAFETY OUTCOME

Runtime integration plan preserves:

Single source of truth
Deterministic registry behavior
Governed mutation path
No shadow state risk

Registry remains:

Governed
Deterministic
Single-instance
Non-self-modifying beyond allowed metadata path

────────────────────────────────

NEXT TARGET

Phase 152B — Runtime Read Surface Attachment Design

