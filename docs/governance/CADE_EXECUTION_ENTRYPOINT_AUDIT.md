
# Cade Execution Entrypoint Audit

Date: 2026-07-06

## Objective

Identify all current execution entrypoints, implicit authorization paths, and any bypass routes that could trigger Cade execution outside the canonical gate.

## 1. Entry Point Scan (Execution + Cade + Matilda Routes)

## server route + execution keyword scan

$(grep -RniE "cade|execution|execution_authorized|enterCade|matilda.*execution|/api/matilda|scheduler|orchestration" server --exclude-dir=node_modules --exclude-dir=.git || true)

## 2. Direct Execution Gate References

$(grep -RniE "execution_authorized|execution_switch|EXECUTABLE|plan_review_ready|preview_confirmed" server db docs --exclude-dir=node_modules --exclude-dir=.git || true)

## 3. Potential Entry Surfaces (HTTP Routes)

$(grep -RniE "app\\.post|router\\.post|/api/matilda|execution-authorization|execution-planning|preview-confirmation|preview" server --exclude-dir=node_modules --exclude-dir=.git || true)

## 4. Summary (Generated)

- This audit lists all discovered execution-adjacent surfaces.

- Review is required to ensure all Cade execution paths route through enterCadeExecution(ctx).

- Any direct execution without the canonical gate is a violation of the execution model.

