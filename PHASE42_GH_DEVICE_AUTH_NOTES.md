# Phase 42 — GitHub CLI Device Auth (Code Mismatch Fix)

## The mismatch
GitHub CLI ("gh") uses **Device Flow** auth:
- It prints an **8-character** code like: `ABCD-EFGH`
- You must enter that exact code at: https://github.com/login/device

This is NOT the same as:
- Your 2FA authenticator 6-digit OTP code, or
- Any shorter "auth app" code.

## Correct flow
1) Run: `gh auth login -h github.com -p https -s repo,workflow`
2) Copy the device code shown (format `XXXX-XXXX`)
3) Open: https://github.com/login/device
4) Paste the device code
5) Continue in browser (you may be asked to confirm password / 2FA)
6) Return to terminal: the `gh auth login` command will complete automatically

## If you already started a device flow
If the terminal is currently waiting, use the code it printed (e.g., `BD95-0C71`).
Do NOT look in the authenticator app for it.

## Verify
- `gh auth status -h github.com`

## Note on branch protection APIs
If Settings → Branches shows "Classic branch protections have not been configured",
your repo may be using **Rulesets** instead of classic branch protection.
Classic endpoints like `/branches/main/protection/...` will return 404 in that case.
