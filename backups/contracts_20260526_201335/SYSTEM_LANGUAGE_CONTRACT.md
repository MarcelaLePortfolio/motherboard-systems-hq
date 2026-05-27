
# SYSTEM LANGUAGE CONTRACT

## 1. EXECUTION VS UI SEMANTICS

The system distinguishes strictly between execution state and user interface state.

Execution state refers to backend truth (task lifecycle, database state, agent routing).

UI state refers to ephemeral presentation constructs used only for user readability.

UI constructs must never be treated as execution authority.

---

## 2. ROLE DEFINITIONS

Cade = task routing / delegation role  

Matilda = conversational interface role  

Agent roles describe functional responsibility only and do not imply system authority or autonomy.

---

## 3. AGENT POOL VISUALIZATION RULE

Agent pool UI elements are optional visualizations of roles and system activity.

They are not execution infrastructure.

They must never be interpreted as authoritative system state.

---

## 4. SOURCE OF TRUTH HIERARCHY

1. tasks.status → authoritative task lifecycle state  

2. agent_status table → assignment / presence mapping only  

3. UI state → ephemeral rendering layer with no authority  

---

## 5. UI STATE RULES

UI may display transient states such as “thinking” for responsiveness.

UI must never infer system execution capability from agent presence or status labels.

BUSY/IDLE or similar labels are descriptive only and not guarantees of execution.

---

## 6. ILLUSION BOUNDARY RULE

UI is permitted to use simplified or human-readable states for clarity.

UI is not permitted to imply capabilities that do not exist in the runtime system.

Any ambiguity must default to “intent / observation only”.

---

## 7. MATILDA UX DECOUPLING

Matilda chat UX is allowed to use ephemeral states (e.g. “thinking”, “responding”).

These states are purely client-side or presentation-layer signals.

They must not affect backend execution semantics or task state.

---

## 8. SEMANTIC SAFETY PRINCIPLE

Labels describe perception, not authority.

System truth must remain strictly separable from user-facing narrative constructs.

---

## 9. ALLOWED STATUS MODEL (CADE / MATILDA)

### Cade (Routing Agent) Allowed UI States

- idle

- routing

- delegating

- awaiting_confirmation

Cade status reflects routing pipeline visibility only and does not indicate execution completion or system workload.

---

### Matilda (Conversation Agent) Allowed UI States

- idle

- thinking

- responding

- waiting_input

“thinking” is a purely visual affordance and must never be interpreted as backend computation or execution activity.

---

## 10. NON-AUTHORITY GUARANTEE

No agent status, UI label, or role descriptor may override task table state or backend execution truth.

All UI states are explicitly non-authoritative and may be safely inconsistent with backend execution timing.

