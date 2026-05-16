
# Phase 723 Manual Browser Validation

## Objective

Record manual browser validation for the activated Phase 723 visual artifact preview wrapper.

## Current HEAD

`1b82cfae`

## Browser Validation Checklist

Validate at:

`http://localhost:3000`

Required checks:

- dashboard loads after hard refresh

- Recent Tasks renders

- existing completed artifact Preview opens

- existing semantic artifact rendering appears

- no duplicate rendering regression appears

- markdown fallback remains readable

- browser console shows no Phase 723 errors

- dashboard refresh preserves Agent Pool visibility

- task polling remains stable

## Visual Marker Validation

Only validate visual marker rendering if a test artifact containing markers is available.

Required markers:

`<!-- visual-artifact:start -->`

`<!-- visual-artifact:end -->`

Expected visual-marker behavior:

- Visual Artifact block appears above semantic fallback

- semantic fallback still appears

- unsafe tags are not required for the test

- no iframe/srcdoc rendering appears

- no duplicate preview stack appears

## Result

Manual validation result:

PENDING

## Notes

Add observed result here after browser validation.

## Rollback Boundary

If any browser regression appears, revert the activation correction commit and return to the inactive-wrapper baseline.

