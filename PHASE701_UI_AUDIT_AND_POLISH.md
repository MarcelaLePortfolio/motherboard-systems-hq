# Phase 701 — Full UI Audit (Verification + Polish Targets)

## Scope

Comprehensive visual + functional audit of Operator Console screenshot.

This is NOT a re-architecture.  
This identifies:

- Verification gaps (things that may be incorrect or misleading)
- Polish gaps (clarity, UX, consistency, trust)

---

## 1. GLOBAL SYSTEM SIGNALS

### ⚠️ Health Indicator vs Reality

- Top bar shows: **Health: Critical**
- BUT:
  - No strong visual emphasis elsewhere
  - No escalation in layout or color hierarchy

### Gap

- “Critical” is visually underweighted
- No clear reason surfaced inline

### Action

- Verify: health calculation logic
- Add:
  - Reason summary (e.g. “Execution not verified”)
  - Stronger visual priority (color / icon)

---

## 2. AGENT POOL

### Observations

- All agents: **offline**
- Includes:
  - Matilda
  - Atlas
  - Cade
  - Effie

### Gaps

- No explanation WHY offline
- No distinction between:
  - Not started
  - Failed
  - Disabled
- No timestamp / last seen

### Action

- Verify agent lifecycle source
- Add:
  - Status reason
  - Last heartbeat
  - Optional “expected state”

---

## 3. KPI CARDS (TOP RIGHT)

### Cards:

- Active Agents → `--`
- Tasks Running → `--`
- Success Rate → `--`
- Latency → `--`

### Gaps

- `--` is ambiguous:
  - Is it loading?
  - No data?
  - Failure?

### Action

- Replace with explicit states:
  - “No data”
  - “Initializing”
  - “Unavailable”

- Verify:
  - Data source wiring
  - Polling or SSE feed

---

## 4. OPERATOR WORKSPACE (CHAT)

### Observations

- Placeholder: “Chat with Matilda…”
- Input exists
- Send button exists
- “Quick check” button exists

### Critical Gap

Text below says:

> “Matilda is currently using a placeholder /api/chat stub (Phase 11.3 baseline).”

### This is a **real functional gap**, not polish.

### Issues

- System is “complete” but chat is not real
- Breaks expectation of operator console

### Action

- Verify:
  - Is Ollama integration active?
  - Is fallback intended?

- Decide:
  - Replace placeholder OR
  - Re-label as “demo mode”

---

## 5. OPERATOR GUIDANCE PANEL

### Observations

- Shows: **“No guidance available”**

### Conflict

Telemetry shows:
- Failures
- Retries
- Logs

### Gap

Guidance system is:
- Working (based on backend phases)
- But NOT surfacing here

### Action

- Verify:
  - `/api/guidance` consumption
  - Render condition logic

- Likely issue:
  - Filtering
  - Timing
  - Mapping mismatch

---

## 6. GUIDANCE HISTORY

### Observations

- Shows:
  - “27 snapshots”
  - Last message summary

### Gaps

- No:
  - Scrollable list
  - Detail view
  - Interaction

### Action

- Optional polish:
  - Expandable history
  - Click to inspect snapshot
  - Link to comparison

---

## 7. TELEMETRY CONSOLE

### Sections:

- Recent Tasks
- Recent Logs

### Observations

- Tasks:
  - Retry test-failure (completed)
  - test-failure (failed)

- Logs:
  - Clean timestamps
  - Clear status labels

### Gaps

- No:
  - Duration
  - Agent attribution
  - Error reason

### Action

- Verify:
  - task_events richness

- Add:
  - Duration
  - Failure cause
  - Retry chain link

---

## 8. ATLAS SUBSYSTEM STATUS

### Observations

- Status: **Degraded**
- Core Engine: **Initializing…**

### Gap

- “Degraded” + “Initializing” mismatch
- No explanation

### Action

- Verify:
  - Status computation logic

- Add:
  - Reason string
  - Progress indicator (optional)

---

## 9. LAYOUT + VISUAL HIERARCHY

### Strengths

- Clean spacing
- Strong grouping
- Consistent card styling

### Gaps

- Critical signals under-emphasized:
  - Health
  - Failures
  - Offline agents

### Action

- Increase contrast for:
  - Critical states
  - Warnings

- Improve scan hierarchy:
  - Use color more decisively

---

## 10. CONSISTENCY ISSUES

### Terminology

- “Offline”
- “Degraded”
- “Critical”
- “Initializing”

These are NOT clearly defined or aligned.

### Action

- Standardize system states:

Example:

- Healthy
- Degraded
- Critical
- Offline
- Initializing

Define meaning + triggers.

---

## 11. TRUST GAPS (IMPORTANT)

These reduce operator confidence:

1. Chat is stubbed
2. KPIs show `--`
3. Guidance says none, but failures exist
4. Health is critical without explanation

### These are the ONLY true “system credibility gaps”

---

## 12. WHAT DOES NOT NEED WORK

Confirmed strong:

- Observability pipeline (already proven)
- Coherence system
- Persistence + retention
- Snapshot system (not visible here but implemented)
- UI architecture (clean and scalable)

---

## FINAL CLASSIFICATION

### NOT CORE SYSTEM GAPS

System backend = complete and sealed.

### UI / OPERATOR LAYER GAPS

1. State clarity
2. Data wiring visibility
3. Expectation alignment
4. Placeholder removal or labeling

---

## PRIORITY ORDER

### Tier 1 (Real Issues)

1. Chat stub (Matilda)
2. Guidance not surfacing
3. KPI ambiguity (`--`)
4. Health explanation missing

### Tier 2 (Clarity)

5. Agent offline reasoning
6. Atlas degraded explanation
7. Terminology alignment

### Tier 3 (Polish)

8. Visual emphasis tuning
9. History interaction
10. Telemetry enrichment

---

## Phase 701 Conclusion

The system is:

- Architecturally complete
- Functionally stable

But the UI still:

- Hides truth in some places
- Under-explains critical states
- Contains one major placeholder (chat)

This is now a **presentation + trust layer refinement phase**, not a system build problem.

