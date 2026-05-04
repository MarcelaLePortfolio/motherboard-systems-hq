# Phase 671 — UI Confirmation & Operator Visibility

Status: READY FOR VERIFICATION

What should now be visible in the dashboard:

- A panel titled **Operator Guidance**
- It shows a count (e.g. Operator Guidance (2))
- Sections grouped by severity:
  - CRITICAL (red, top)
  - WARNING (yellow, middle)
  - INFO (blue, bottom)

Given your current test state, you should see:

CRITICAL
- execution
- "Execution subsystem is not verified."

WARNING
- task-retries
- "Retried tasks are present in recent task history."

Each item should also show:
- subsystem label
- message
- optional "Hint" line (suggested_action)

If you do NOT see it:

1. Hard refresh browser (Cmd + Shift + R)
2. Confirm you are on the main Operator Dashboard page
3. Wait ~5 seconds (polling fallback interval)
4. Check that GuidancePanel is rendered inside OperatorDashboard

