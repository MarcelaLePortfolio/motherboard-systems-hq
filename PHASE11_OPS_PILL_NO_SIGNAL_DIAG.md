
# Phase 11 – OPS Pill NO SIGNAL Greps (Extended)

We are still seeing the OPS pill flip between:

* "OPS: Online"
* "NO SIGNAL"

Earlier greps only checked for the exact uppercase string "NO SIGNAL" and found it only in docs/git history.

To catch case variants from older logic or other writers, also check:

1. Case/spacing variants in source:

   * grep -n "No signal" -R .
   * grep -n "No Signal" -R .
   * grep -n "NO Signal" -R .

2. Any remaining pill writers by ID:

   * grep -n "ops-status-pill" -R public

Use the terminal output of those commands in the next ChatGPT message so we can pinpoint and remove any remaining code paths that write "NO SIGNAL" or otherwise override the pill text.
