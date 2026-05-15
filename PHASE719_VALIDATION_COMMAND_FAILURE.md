
# PHASE 719 — VALIDATION COMMAND FAILURE

## RESULT

The validation task creation command failed before a task was created.

## CAUSES

1. zsh line-continuation parsing split the curl flags into standalone commands.

2. `/api/tasks` does not accept direct POST in this runtime path.

## CLASSIFICATION

Validation command failure only.

No evidence that the worker markdown enrichment patch failed.

## NEXT SAFE STEP

Use the known delegated task route instead of direct `/api/tasks` POST.

