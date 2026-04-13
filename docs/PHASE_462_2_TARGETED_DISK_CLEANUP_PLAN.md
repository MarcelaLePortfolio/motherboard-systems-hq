PHASE 462 — STEP 2
TARGETED DISK CLEANUP PLAN (SAFE, CONTROLLED)

OBJECTIVE

Free sufficient disk space to restore system stability
WITHOUT risking project integrity.

Current state:

• ~7.4 GB free (unsafe for continued dev)
• Target: 15–20 GB free

Primary storage usage:

• ~/Projects → 89G
• ~/Desktop → 23G

────────────────────────────────

SAFE CLEANUP STRATEGY

PRIORITY 1 — DESKTOP (LOW RISK, HIGH IMPACT)

Desktop often contains:

• screenshots
• downloads
• temporary files
• exported assets

Action:

1. Review Desktop manually
2. Delete obvious non-critical files
3. Empty Trash

Expected gain:

5–15 GB

────────────────────────────────

PRIORITY 2 — PROJECTS (CONTROLLED)

Projects is largest (89G)

DO NOT mass delete.

Instead:

1. Identify OLD or DUPLICATE projects
2. Look for:

• archived folders
• backup zips
• unused repos
• old builds

Safe targets:

• old backup folders
• duplicate repos
• large zip archives

────────────────────────────────

IMMEDIATE SAFE ACTION (RECOMMENDED)

Move large non-critical Desktop files to Trash:

Then run:

rm -rf ~/.Trash/*

Check space:

df -h /

────────────────────────────────

OPTIONAL (SAFE) PROJECT CLEANUP

Inside large projects:

Remove build artifacts ONLY:

• node_modules (can reinstall)
• .next
• dist
• build

DO NOT delete:

• src
• docs
• scripts
• configs

────────────────────────────────

EXPLICIT NON-GOALS

• No blind deletion
• No system file removal
• No library tampering
• No project structure damage

────────────────────────────────

STOP CONDITION

Cleanup is COMPLETE when:

• ≥15 GB free space achieved
• system responsiveness stable
• git operations succeed

