# Phase 11 – Dashboard HTML Restore and Bundling Wiring

## Problem

- public/dashboard.html no longer exists.
- Multiple dashboard.html copies exist in snapshot/backup locations.
- The most recent, canonical source is: Backups/current_dashboard/dashboard.html

## Restore Plan

1. Restore dashboard.html → public/dashboard.html
2. Strip legacy <script> tags
3. Inject <script src="/bundle.js"></script>
4. Commit changes and wire to feature/js-bundling

