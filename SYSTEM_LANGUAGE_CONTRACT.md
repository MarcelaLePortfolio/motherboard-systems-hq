
# SYSTEM LANGUAGE CONTRACT — EXECUTION / UI / ROLE SEMANTICS (v1)

## 1. EXECUTION VS INTENT

The system is an intent-routing and task coordination system, not an execution authority.

No UI element, label, or status may imply actual execution unless a verified execution worker is active.

Terms like “delegated”, “queued”, “assigned”, or “thinking” represent intent state only.

## 2. SIMULATION LANGUAGE RULE

The word “simulated” is allowed only in presentation/UI layers.

It may be used to clarify non-authoritative or non-executing state.

It MUST NOT be stored as system truth or persisted as canonical task state.

## 3. AGENT MODEL DEFINITION

“Agents” are interface roles, not autonomous workers.

Cade = task routing / delegation role  

Matilda = conversational interface role  

Agent pool UI elements are optional visualizations of roles, not execution infrastructure.

## 4. SOURCE OF TRUTH HIERARCHY

task table (tasks.status) = authoritative task lifecycle state  

agent_status table = assignment / presence mapping only  

UI state = ephemeral rendering layer with no authority

## 5. UI STATE RULES

UI may display transient states such as “thinking” for responsiveness.

UI must never infer system execution capability from agent presence or status labels.

“BUSY” may only be used if explicitly defined as assignment state, not execution.

## 6. ILLUSION BOUNDARY RULE

UI is permitted to use simplified or human-readable states for clarity.

UI is not permitted to imply capabilities that do not exist in the runtime system.

Any ambiguity must default to “intent / observation only”.

## 7. MATILDA UX IS DECOUPLED FROM SYSTEM STATE

Matilda chat UX is allowed to use ephemeral states (e.g. “thinking”).

These states are purely client-side or presentation-layer signals.

They must not affect or represent backend execution semantics.

## 8. SEMANTIC SAFETY PRINCIPLE

Labels describe perception, not authority.

System truth must remain separable from user-facing narrative constructs.

