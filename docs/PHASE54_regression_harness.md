# Phase 54: Regression Stability Harness

Goal: Prove policy mode behavior stays stable without changing architecture.

## What it proves

- shadow mode: POST /api/policy/probe returns 201 and DB shows writes occurred
- enforce mode: POST /api/policy/probe returns 403 and DB shows no writes occurred

Writes are validated by comparing tasks and task_events row counts before/after the probe.

## Run locally

bash scripts/phase54_regression_harness.sh

## CI

GitHub Actions workflow: .github/workflows/phase54_regression.yml
Runs on PRs and pushes to main.
