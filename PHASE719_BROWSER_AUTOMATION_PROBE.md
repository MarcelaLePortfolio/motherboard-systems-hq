
# PHASE 719 — BROWSER AUTOMATION PROBE

## PURPOSE

Add a read-only browser automation probe to inspect the live rendered preview modal without relying on the cluttered browser DevTools console.

## SCRIPT

`PHASE719_BROWSER_AUTOMATION_PROBE.sh`

## SCOPE

The probe checks:

- Docker runtime state

- served frontend JavaScript

- task/artifact API payload

- Preview button availability

- modal dimensions

- preview body dimensions

- iframe dimensions

- iframe inline styles

- recent browser console messages

- screenshot capture

## SAFETY

This does not modify:

- worker artifact generation

- artifact persistence

- database schema

- retry/requeue behavior

- backend routes

- frontend implementation

