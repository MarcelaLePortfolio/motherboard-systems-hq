# Structured Logger — Safe Usage Guide

Purpose:
Provide a non-invasive, execution-safe way to emit structured observability logs.

## Rules (DO NOT VIOLATE)

- Do NOT place inside execution-critical paths
- Do NOT block or await logging
- Do NOT introduce side effects
- Logging failure must NEVER impact execution

## Safe Example (non-critical edge only)

import { structuredLog } from "./structuredLogger.mjs";

// Example usage at safe boundary (e.g. after response sent, or debug-only path)
structuredLog("retry.completed", {
  mode: "standard",
  taskId: "123",
});

## Output Format

OBS_EVENT {"ts":"ISO_TIMESTAMP","event":"name","...payload}

## Notes

- Console-only (no DB coupling)
- Failure-isolated
- Fully removable without impact
