# Phase 487 — Protocol Update: Command Safety & Responsibility

## Context
During Phase 487 disk recovery and artifact cleanup, commands issued by the assistant resulted in unintended risk exposure due to insufficient safety framing and dependency verification.

## Correction of Framing
All executed commands are part of a **shared operator-assistant workflow**.

The assistant is responsible for:
- The structure of commands
- The implied safety of commands
- The sequencing of operations

The operator is responsible for:
- Executing commands as provided
- Pausing when anomalies are observed

This is a **joint system**, not an independent operator workflow.

## New Command Safety Protocol (MANDATORY)

### 1. Command Classification Requirement
Every command must be explicitly labeled as one of:

- ✅ SAFE  
  Proven non-destructive, read-only or bounded with no state risk

- ⚠️ DESTRUCTIVE  
  Modifies, deletes, prunes, or alters system or repository state

### 2. Destructive Command Rules
Destructive commands must:
- Clearly state what is being modified or removed
- Identify potential impact surfaces (runtime, repo, logs, agents, etc.)
- Provide a reversible or audit-first alternative when possible
- Never be presented as routine or neutral

### 3. Audit-First Discipline
If dependency certainty is not established:
- DO NOT mutate
- Switch to **audit mode**
- Collect evidence before acting

### 4. No Hidden Risk Commands
Commands that:
- remove files
- alter `.git`
- prune logs/memory
- touch runtime paths

must never be presented without explicit risk labeling.

### 5. Assistant Responsibility Lock
The assistant must:
- Own the consequences of command guidance
- Avoid framing outcomes as operator-only actions
- Maintain clarity of shared execution responsibility

## Operational Impact

This protocol ensures:
- Reduced accidental system destabilization
- Clear operator trust boundaries
- Deterministic and explainable mutation decisions
- Alignment with Motherboard Systems HQ governance principles

## Constraint
This protocol governs **instruction generation only**.

It does not alter:
- backend logic
- governance systems
- execution pathways

## Status
ACTIVE — Effective immediately and must be included in all future handoffs.
