
# Project Registry V2-B Path Inspection Endpoint — 2026-07-03

## Status

Project path inspection endpoint is implemented and validated.

## Endpoint

`POST /api/projects/inspect-path`

## Validated Responses

- Empty path returns guidance: `Enter a project root path.`

- Invalid path returns: `Project root path does not exist.`

- Current repository path returns: `Ready to register.`

- Response includes:

  - `ok`

  - `inputPath`

  - `resolvedPath`

  - `exists`

  - `isDirectory`

  - `isGitRepository`

  - `message`

## Scope Boundary

This endpoint is read-only.

It does not:

- register projects

- mutate Active Context

- write to SQLite

- bypass backend registration validation

## Next Milestone

Wire modal path input to the inspection endpoint for live read-only feedback.

