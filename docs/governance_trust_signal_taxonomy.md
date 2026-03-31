# Governance Trust Signal Taxonomy
Phase: 401.9  
Classification: Trust Signal Classification Layer  
Runtime Impact: NONE  
Execution Impact: NONE  

## Purpose

Define the allowed classes of trust signals without changing trust meaning.

Taxonomy organizes trust signals.
Taxonomy does NOT redefine trust.

## Trust Signal Classes

Trust signals may belong only to these classes:

• Evidence Trust
Confidence based on presence and completeness of supporting governance evidence.

• Replay Trust
Confidence based on deterministic replay verification success.

• Determinism Trust
Confidence based on determinism verification stability.

• Consistency Trust
Confidence based on cross-signal agreement.

• Explanation Trust
Confidence based on completeness of governance explanations.

• Coverage Trust
Confidence based on completeness of governance evaluation coverage.

• Reliability Trust
Confidence based on signal stability across replay and restart.

## Trust Signal Class Rules

Each trust signal must:

Belong to exactly one primary class.

Trust signals may reference secondary context but must maintain one classification anchor.

## Trust Class Boundaries

Trust classes must NOT:

Overlap in meaning  
Duplicate semantics  
Introduce authority meaning  
Introduce execution meaning  

## Trust Classification Rules

Classification must depend only on:

Signal origin  
Signal purpose  
Signal evidence type  
Signal verification method  

Classification must NOT depend on:

Confidence value  
UI representation  
Operator interpretation  
Presentation formatting  

## Trust Class Stability

Trust classes must remain:

Stable across governance refactors  
Stable across replay  
Stable across documentation changes  

Trust classes may only change if:

A new governance cognition capability is introduced.

## Completion Condition

Phase 401.9 considered stable when:

All trust signals can be classified without ambiguity.
