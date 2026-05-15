
# PHASE 719 — BROWSER VALIDATION CHECKLIST

## CURRENT HEAD

`b173b9d5`

## VALIDATION TARGET

Validate the committed frontend-only embedded artifact preview polish in the browser.

## MANUAL BROWSER CHECKLIST

Open:

`http://localhost:3000`

Confirm:

- Dashboard loads normally

- Recent Tasks render normally

- Completed artifact tasks still show Preview pill

- Preview pill opens modal

- Modal title/subtitle/meta render correctly

- Loading state appears briefly or safely

- iframe preview renders visual card content

- Modal body scrolls without breaking layout

- iframe does not overflow awkwardly

- Close button works

- Escape key closes modal

- Retry/requeue controls remain visible and unchanged

- No obvious browser console errors appear

## PASS CONDITION

The patch passes if preview containment feels improved and no execution/retry UI regression appears.

## FAIL CONDITION

If modal layout is worse or preview is broken, revert only:

`9e552128`

Then reassess from stable checkpoint.

