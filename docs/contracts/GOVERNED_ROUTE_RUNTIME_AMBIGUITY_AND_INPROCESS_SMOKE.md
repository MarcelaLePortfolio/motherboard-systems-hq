
# Governed Route Runtime Ambiguity and In-Process Smoke

## Context

A live HTTP smoke against `http://localhost:3000/api/governed-planning/dry-run` returned `Recv failure: Connection reset by peer`.

Follow-up diagnosis showed:

- port 3000 was owned by Docker Desktop proxy

- no running Docker container was visible from `docker ps`

- PM2 had no active processes

- the governed route imported successfully

- the local governed route pipeline smoke passed

## Finding

The failure is classified as runtime target ambiguity, not a governed route implementation failure.

The live HTTP request was not a reliable validation surface because the listener on port 3000 could not be mapped to a visible active application container or PM2 process.

## Safe Validation Replacement

The route is validated in-process by importing the Express router, locating:

`POST /api/governed-planning/dry-run`

and invoking the handler with a mocked request/response pair.

## Boundary Preserved

The in-process smoke verifies route behavior without:

- filesystem mutation

- shell execution

- autonomous execution

- PM2 mutation

- Docker mutation

- legacy run_shell promotion

## Locked Meaning

Live HTTP route testing must not continue until the runtime owner of port 3000 is unambiguous.

Governed planning route behavior remains valid at the static and in-process route level.

