# PHASE 87.1 — SITUATION SUMMARY COMPOSER

Status: IN PROGRESS  
Date: 2026-03-18

────────────────────────────────

## OBJECTIVE

Introduce deterministic SituationSummary composition from existing cognition and signal summaries.

Pure composition only.

No reducers  
No telemetry changes  
No execution logic  
No authority changes  

────────────────────────────────

## PHASE BOUNDARY

Allowed:

• Read existing signal summaries  
• Read cognition summaries  
• Read system health summaries  
• Compose SituationSummary object  
• Normalize operator scanning language  

Forbidden:

• New signals  
• New metrics  
• Risk engines  
• Confidence engines  
• Early warning systems  
• Automation behaviors  
• Policy changes  

────────────────────────────────

## RESULT TARGET

Create deterministic composition unit answering:

• System posture  
• Stability state  
• Signal coherence  
• Operator attention need  
• Immediate execution concerns

No runtime behavior changes.

────────────────────────────────

## INPUT CONTRACT

Composer consumes only existing summaries:

• Signal summaries  
• Cognition summaries  
• System health summaries  
• Operator summaries

No lower-level recomputation.

Repo truth only.

────────────────────────────────

## OUTPUT CONTRACT

SituationSummary structure:

type SituationSummary = {
  stabilityState: "stable" | "degraded" | "unknown";
  executionRiskState: "none" | "elevated" | "unknown";
  cognitionState: "consistent" | "mixed" | "unknown";
  signalCoherenceState: "coherent" | "divergent" | "unknown";
  operatorAttentionState: "none" | "recommended" | "required";
  summaryLines: string[];
};

Structure only.  
No UI coupling.

────────────────────────────────

## SUMMARY LINE RULES

Lines must be:

Deterministic  
Signal-derived  
Brief  
Operator-readable  
Non-speculative  

Allowed style:

SYSTEM STABLE  
SIGNALS COHERENT  
NO EXECUTION RISK DETECTED  
NO OPERATOR ACTION REQUIRED  

Forbidden:

Probably safe  
May become issue  
Narrative language  
Forward interpretation  

────────────────────────────────

## DETERMINISM RULE

Identical inputs → identical outputs.

No timestamps in interpretation.  
No randomness.  
No environment formatting.  

Fixed ordering:

1 Stability  
2 Execution risk  
3 Cognition state  
4 Signal coherence  
5 Operator attention  

────────────────────────────────

## IMPLEMENTATION TARGET

Create composer file:

src/cognition/situationSummaryComposer.ts

Pure function:

composeSituationSummary(inputs) → SituationSummary

No side effects.  
No IO.  
No logging.

────────────────────────────────

## PHASE DISCIPLINE

Remain:

Deterministic  
Incremental  
Auditable  
Reversible  

No forward fixes.

Future cognition layers not implemented here.

Record only.

────────────────────────────────

END PHASE 87.1 DOCUMENT
