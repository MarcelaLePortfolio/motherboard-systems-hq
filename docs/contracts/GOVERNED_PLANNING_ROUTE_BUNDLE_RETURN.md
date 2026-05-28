
# Governed Planning Route Bundle Return

## Context

The governed planning route now returns the canonical governed planning artifact bundle.

## Commit Under Test

e5d08008 Return canonical bundle from governed planning route

## Route

    POST /api/governed-planning/dry-run

## Response Shape

Successful route responses now return:

    {

      "ok": true,

      "route": "governed_planning_dry_run",

      "mode": "planning_only",

      "bundle": {

        "bundle_schema": "governed_planning_artifact_bundle.v1",

        "response": {},

        "reconciliation": {},

        "audit_ledger": {},

        "execution_authority": {

          "mutation_performed": false,

          "shell_execution_performed": false,

          "autonomous_execution_performed": false

        }

      }

    }

Failed route responses now return a normalized governed response artifact:

    {

      "ok": false,

      "failed_closed": true,

      "route": "governed_planning_dry_run",

      "mode": "planning_only",

      "response": {

        "response_schema": "governed_planning_response.v1",

        "ok": false,

        "execution_authority": {

          "mutation_performed": false,

          "shell_execution_performed": false,

          "autonomous_execution_performed": false

        }

      }

    }

## Stabilized Meaning

The route no longer exposes raw pipeline internals as its primary successful response.

The route now emits the canonical non-executing artifact bundle containing:

- normalized governed response

- normalized reconciliation artifact

- governed execution audit ledger

## Boundary Preserved

The route remains:

- planning only

- dry-run only

- non-mutating

- shell-free

- non-autonomous

- reconciliation-ready

- audit-ready

## Explicit Non-Authority

The route does not authorize:

- filesystem mutation

- shell execution

- autonomous execution

- PM2 runtime mutation

- recursive delegation

- legacy run_shell promotion

## Future Constraint

Server registration or UI exposure must preserve this canonical bundle response.

No route consumer may infer mutation authority from a successful route response.

