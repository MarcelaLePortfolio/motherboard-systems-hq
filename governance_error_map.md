TYPECHECK ERROR SURFACE CLASSIFICATION REPORT

────────────────────────────────────────────

1. GOVERNANCE API / EXPORT DRIFT (CRITICAL - SYSTEMIC)

Symptoms:
- Missing exports from ../../src/governance/cognition
- Examples:
  - proveGovernanceCognitionSnapshot
  - selectGovernanceDashboardConsumptionView
  - proveGovernanceRuntimeRegistryExport
  - selectGovernanceSharedRegistryOwnerBundle

Root Cause:
- Governance cognition modules out of sync with index re-exports
- Feature modules exist but are not exported or renamed inconsistently

Fix Strategy:
- Standardize export surface in src/governance/cognition/index.ts
- Align naming: prove* vs select* vs snapshot variants
- Remove duplicate or legacy export aliases

Priority: P0

────────────────────────────────────────────

2. DOMAIN MODEL DRIFT (HIGH PRIORITY)

Symptoms:
- SituationSummary missing governanceCognitionState
- Duplicate operationalConfidence definitions
- Type mismatch across cognition pipeline

Root Cause:
- Multiple competing schema definitions across cognition modules

Fix Strategy:
- Consolidate SituationSummary into single canonical interface
- Remove duplicate property declarations
- Normalize operationalConfidence to single shape

Priority: P0

────────────────────────────────────────────

3. MIRROR / MATILDA IMPORT RESOLUTION (MEDIUM)

Symptoms:
- Cannot find module '../../mirror/agent'
- Path resolution inconsistencies in scripts vs agents

Root Cause:
- tsconfig rootDir + moduleResolution mismatch
- Mixed relative import assumptions

Fix Strategy:
- Set moduleResolution to Node
- Standardize mirror imports to project-root resolution

Priority: P1

────────────────────────────────────────────

4. TYPESCRIPT / REACT JSX ENV (MEDIUM)

Symptoms:
- JSX runtime missing
- react/jsx-runtime not found

Root Cause:
- Missing React type packages

Fix Strategy:
- Install @types/react @types/react-dom

Priority: P1

────────────────────────────────────────────

5. REPLAY DIAGNOSTIC ENUM DRIFT (MEDIUM)

Symptoms:
- EVENT_ORDERING invalid
- DUPLICATE_SEQUENCE invalid
- REPLAY_EMPTY invalid

Root Cause:
- Test fixtures not aligned with enum contract

Fix Strategy:
- Sync replay_violation_codes with test suite

Priority: P2

────────────────────────────────────────────

6. GOVERNANCE SIGNAL FRAGMENTATION (HIGH)

Symptoms:
- Missing governance_signals/system_view
- Enum mismatches in severity logic

Root Cause:
- Multiple governance pipelines defining overlapping models

Fix Strategy:
- Consolidate governance signal schema into single source of truth

Priority: P0

────────────────────────────────────────────

7. TS CONFIG STRUCTURAL ISSUES (FOUNDATIONAL)

Symptoms:
- Cross-root module resolution instability
- Mixed include boundaries across src/scripts/agents/mirror

Root Cause:
- No explicit workspace boundary definition

Fix Strategy:
- Introduce module aliasing or monorepo segmentation

Priority: P0
