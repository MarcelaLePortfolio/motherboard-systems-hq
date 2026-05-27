# Phase 11 – Feature Branches Overview

This file documents the Phase 11 feature branches created from the stable dashboard baseline.

_Last updated: Phase 11 feature branches created from tag `v11.1-stable-dashboard`._

## Golden Baseline

- Tag: `v11.1-stable-dashboard`
- Purpose: Known-good dashboard with working SSE (OPS @3201, Reflections @3200)

## Feature Branches

1. `feature/js-bundling`
   - Base: `v11.1-stable-dashboard`
   - Scope:
     - Introduce JS/CSS bundling (e.g., via esbuild or rollup)
     - Output a single `public/bundle.js`
     - Update `dashboard.html` to use the new bundle instead of multiple `<script>` tags
     - Preserve existing SSE behavior and dashboard functionality

2. `feature/staging-pm2-setup`
   - Base: `v11.1-stable-dashboard`
   - Scope:
     - Duplicate PM2 config into a staging profile (e.g., `pm2-staging.config.cjs`)
     - Register a `main-staging` process family in PM2
     - Keep production / main profile behavior unchanged

## Notes

- These branches are intentionally created from the stable tag to keep experimental work isolated.
- All risky changes (bundling, staging PM2 profile) should happen on these branches, not directly on the mainline.
- The current working branch remains the primary integration branch, with this file recording the branching strategy for future reference.
