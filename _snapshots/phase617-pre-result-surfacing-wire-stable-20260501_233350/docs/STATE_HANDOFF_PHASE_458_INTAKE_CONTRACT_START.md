STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Post-Phase 457.17 → Phase 458 transition — intake corridor opened,
definition-only posture confirmed, deterministic start)

────────────────────────────────

PHASE 458 — INTAKE CONTRACT DEFINITION

CORRIDOR CLASSIFICATION:

CAPABILITY GAP COMPLETION

PRIMARY OBJECTIVE:

Define deterministic intake layer capable of:

• Accepting arbitrary operator requests  
• Translating into structured project model  
• Producing deterministic planning output  

STRICTLY:

DEFINITION ONLY  
NO EXECUTION  
NO WIRING  

────────────────────────────────

ENGINEERING PROTOCOL BASELINE (ENFORCED)

Workflow discipline:

• Prove before wiring  
• Evidence before mutation  
• Result shape before behavior  
• Single boundary changes  
• One hypothesis per phase  
• Verify before seal  
• Pattern stabilize before expansion  

Mutation discipline:

• Smallest safe change first  
• No deep coupling mutations  
• No multi-layer changes  
• Entrypoint control preferred  

Stability discipline:

• Restore last checkpoint if unstable  
• Never fix forward  
• Prefer restoration over repair  

Checkpoint discipline:

• Always tag stable states  
• Never proceed without anchor  
• Tags define truth  

────────────────────────────────

TERMINAL-SAFE CODEBLOCK PROTOCOL (ENFORCED)

All commands MUST:

• Be inside ONE codeblock  
• Contain zero narrative  
• Be copy-paste executable  
• Anchor to repository root  

Always begin with:

cd "$(git rev-parse --show-toplevel)"

Always:

• Write outputs to docs/  
• Commit before advancing  
• Push after commit  
• Tag checkpoints  

────────────────────────────────

INTAKE LAYER — REQUIRED STRUCTURES

1. OPERATOR REQUEST CONTRACT

OperatorRequest:

• requestId: string  
• timestamp: number  
• rawInput: string  
• inputType: "text" | "structured" | "unknown"  
• source: "operator"  
• metadata: Record<string, unknown>  

Invariant:

• No interpretation  
• No mutation  
• Pure capture  

────────────────────────────────

2. INTAKE NORMALIZATION CONTRACT

NormalizedRequest:

• requestId: string  
• canonicalText: string  
• tokens: string[]  
• detectedIntent: "unknown"  
• ambiguityFlags: string[]  
• normalizationTrace: string[]  

Invariant:

• Deterministic transformation  
• No inference beyond formatting  
• Replay-safe  

────────────────────────────────

3. PROJECT STRUCTURE CONTRACT

ProjectDefinition:

• projectId: string  
• sourceRequestId: string  
• tasks: TaskDefinition[]  
• constraints: string[]  
• assumptions: string[]  
• unknowns: string[]  
• structureTrace: string[]  

TaskDefinition:

• taskId: string  
• description: string  
• dependencies: string[]  
• status: "unplanned"  

Invariant:

• Structure only  
• No execution eligibility  
• No governance yet  

────────────────────────────────

4. PLANNING OUTPUT CONTRACT

PlanningOutput:

• projectId: string  
• orderedTasks: string[]  
• taskGraph: Record<string, string[]>  
• planningTrace: string[]  
• determinismProof: string  

Invariant:

• Same input → same output  
• No randomness  
• No async influence  

────────────────────────────────

5. VALIDATION CONTRACT

ValidationResult:

• valid: boolean  
• violations: string[]  
• validationTrace: string[]  

Rules:

• Missing fields = violation  
• Non-deterministic transforms = violation  
• Implicit assumptions = violation  

────────────────────────────────

GLOBAL INVARIANTS

• No execution triggering  
• No governance evaluation  
• No enforcement mediation  
• No async behavior  
• No external state dependency  

• Replay-safe  
• Deterministic  
• Fully traceable  

────────────────────────────────

PHASE 458 SUCCESS CRITERIA

• Intake contract defined  
• Normalization defined  
• Project structure defined  
• Planning output defined  
• Validation rules defined  
• Determinism invariants proven  

NO IMPLEMENTATION ALLOWED

────────────────────────────────

NEXT STEP (PHASE 458.1)

• Define example input  
• Produce full intake → planning trace  
• Verify determinism  

────────────────────────────────

STATE:

STABLE  
CHECKPOINTED (phase457)  
INTAKE CORRIDOR OPEN  
READY FOR DEFINITION EXECUTION

