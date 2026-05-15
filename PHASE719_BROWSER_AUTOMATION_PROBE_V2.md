
# PHASE 719 — BROWSER AUTOMATION PROBE v2

## PURPOSE

Replace the first probe with a quieter corrected version that avoids noisy full API dumps and runs Playwright through npm package execution.

## CORRECTION

The probe now uses:

`npm exec --yes --package=playwright@latest -- node /tmp/phase719_browser_probe.mjs`

## SCOPE

Read-only inspection only.

