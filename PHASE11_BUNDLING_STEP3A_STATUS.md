
Phase 11 – STEP 3A: Entry File & Bundling Script Inspection
Purpose

STEP 3A is a read-only inspection step before changing any JS or bundler config.

Goals:

See how /bundle.js is currently built (if at all) via package.json scripts.

Inspect public/js/dashboard-bundle-entry.js to understand its current role.

Capture notes that will guide safe entry-file wiring and esbuild setup.

No DB behavior is touched in this step.

1. package.json – Bundling / Build Scripts
Commands to run in terminal

cat package.json | sed -n '1,160p'

(If needed) cat package.json | sed -n '161,320p'

Paste or summarize relevant findings here
Existing build/bundle scripts:
Tool(s) used (esbuild / webpack / other):
Script that appears to generate /bundle.js (if any):
Notes / concerns:
2. public/js/dashboard-bundle-entry.js – Current Behavior
Command to run in terminal

sed -n '1,200p' public/js/dashboard-bundle-entry.js

(If the file is longer, you can also run:)

sed -n '200,400p' public/js/dashboard-bundle-entry.js

Paste or summarize findings
Uses ES module import syntax: (yes/no/unsure)
Imports task-related modules (list):
Imports agent-status-related modules (list):
Imports SSE-related modules (list):
Imports Matilda chat–related modules (list):
Direct DOM or window usage to be careful with:
3. Quick Interpretation Checklist

After inspecting both files, answer briefly:

Is there already a script that builds /bundle.js?
Does dashboard-bundle-entry.js already act as a true orchestrator (one place that calls into everything)?
Which modules are clearly safe to import directly (no heavy top-level side effects)?
Which modules may need to be wrapped in initX() functions to avoid immediate side effects?
Any obvious red flags (duplicate listener patterns, multiple EventSource creations, etc.)?
4. Handoff Notes

Once this file has been updated with:

A summary of package.json build/bundle scripts, and

A summary of dashboard-bundle-entry.js contents,

you’ll be ready for:

STEP 3B – Implement entry file imports + init sequence with concrete code changes.

