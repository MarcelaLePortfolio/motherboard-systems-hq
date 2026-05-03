PHASE 624 — SSE GUIDANCE PATCH PLAN (SAFE INSERTION)

OBJECTIVE:
Expose execution guidance to UI via SSE without altering execution behavior.

CURRENT STATE:
- Guidance already computed in SSE route
- Currently only logged (console)
- Not included in SSE payload

TARGET FILE:
server/routes/task-events-sse.mjs

SAFE INSERTION POINT:
Inside poll() loop AFTER normalizeRow(row)

CURRENT:
  const payload = normalizeRow(row);

PATCH:
  const payload = normalizeRow(row);

  let guidance = null;
  try {
    guidance = interpretCompletedTaskEvent({ ...row, payload });
  } catch {}

  const enrichedPayload = guidance
    ? { ...payload, guidance }
    : payload;

REPLACE SSE WRITE:
FROM:
  data: payload

TO:
  data: enrichedPayload

CONSTRAINTS:
- DO NOT modify existing payload structure
- ONLY append optional "guidance"
- MUST NOT throw if guidance fails
- MUST NOT block SSE loop
- MUST NOT mutate DB or execution

VALIDATION:
- SSE still streams
- Existing UI unaffected
- guidance appears when available
- No errors in logs

ROLLBACK:
- revert enrichedPayload → payload

SUCCESS CRITERIA:
- Guidance visible in SSE stream
- UI can consume without backend changes
- Execution pipeline untouched

SYSTEM IMPACT:
ZERO RISK (READ-ONLY AUGMENTATION)
