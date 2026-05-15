
# PHASE 719 — PREVIEW CONSTRAINT PATCH

## PURPOSE

Apply a narrow frontend-only patch to improve artifact preview modal/iframe constraints based on measured browser metrics.

## MEASURED ISSUE

Before patch:

- dialog width: 760

- dialog height: 685

- dialog scrollHeight: 756

- body width: 726

- body height: 598

- iframe width: 688

- iframe height: 560

## PATCH TARGET

The issue is not missing artifact HTML.

The issue is the baseline modal/iframe constraint shape.

## CHANGE TYPE

Frontend-only preview constraint adjustment.

## FILE MODIFIED

`public/js/phase530_visible_panels_bridge.js`

## SAFETY BOUNDARY

This patch does not modify:

- worker artifact generation

- artifact persistence

- retry/requeue behavior

- task execution routes

- `/api/tasks`

- `/events/task-events`

- artifact preview route

- database schema

