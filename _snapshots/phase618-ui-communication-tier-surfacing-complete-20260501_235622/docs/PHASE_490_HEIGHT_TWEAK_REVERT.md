PHASE 490 — HEIGHT TWEAK REVERT

STATUS:
REVERTING LAST NO-EFFECT HEIGHT TUNE

────────────────────────────────

REASON

Latest telemetry height border-correction tune produced no visible change.

Per build protocol:

• Do not keep layering speculative fixes  
• Revert no-effect attempts cleanly  
• Preserve the last known stable layout state  
• Re-enter later with a different class of solution  

────────────────────────────────

CURRENT CONCLUSION

The remaining mismatch is not responding to small runtime height tuning.

This strongly suggests the issue is controlled by a deeper parent/layout contract,
not by per-card pixel adjustments.

────────────────────────────────

NEXT SAFE ENTRY

Future corridor should start from:

PHASE 490.1 — AUTHORITATIVE PARENT LAYOUT EVIDENCE

Recommended method:

1. Capture exact computed heights and parent constraints  
2. Identify which parent container is enforcing the extra height  
3. Normalize the row/column contract at that parent  
4. Reapply inner scrolling only after parent parity is proven  

────────────────────────────────

ACTION

Revert the last no-effect telemetry height tuning commit only.

