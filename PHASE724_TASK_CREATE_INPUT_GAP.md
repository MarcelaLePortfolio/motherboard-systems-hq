
# Phase 724 Task Create Input Gap

## Finding

The failed natural visual delegation task row stored:

- empty `title`

- empty `payload`

- completed default worker output

## Evidence

Task:

`t_dfb0d1f5-dc5f-4d48-b244-5fea1b4e0096`

Row inspection result:

`title: empty`

`payload: {}`

## Interpretation

The visual interpreter did not fail.

The natural-language request was lost during task creation because `/api/tasks/create` accepted the request but did not persist the delegated text when it arrived outside `title`.

## Required Fix

Patch the task creation route so incoming `description`, `prompt`, `input`, `message`, or `task` can populate `title` when `title` is missing.

## Scope

Modify task creation input normalization only.

Do not modify:

- renderer

- preview route

- worker visual generation logic

- retry contract

- SSE

- DB schema

- polling

- Agent Pool behavior

