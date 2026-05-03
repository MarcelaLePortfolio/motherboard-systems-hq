STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Context clarification — operator requested orientation before next mutation)

────────────────────────────────

WHAT WE ARE DOING (PLAINLY)

You hit a REAL runtime bug:

• Operator Guidance stream restarts when switching tabs

This means:

• Something is re-initializing incorrectly
• The system is NOT idempotent at the UI stream layer
• This is a runtime integrity issue (not theoretical anymore)

────────────────────────────────

WHY WE STOPPED EVERYTHING ELSE

We paused normal feature work because:

• This is a SYSTEM INTEGRITY violation
• If left unfixed, it breaks trust, determinism, and operator visibility

Your protocol correctly triggered:

→ INVESTIGATE FIRST  
→ DO NOT PATCH BLINDLY  

────────────────────────────────

WHAT WE JUST FINISHED

We did NOT fix anything yet.

We:

1. Proved the bug is real (repro confirmed)
2. Scanned the codebase
3. Narrowed it down
4. Selected ONE file to fix

That file is now locked in:

docs/phase464_5_SINGLE_FILE_FIX_TARGET.txt

────────────────────────────────

WHAT COMES NEXT (VERY IMPORTANT)

Now we do the FIRST REAL FIX — but carefully:

PHASE 464.6

We will:

• Open that ONE file
• Add ONE guard (or cleanup)
• Prevent duplicate stream initialization

NOT a rewrite  
NOT multiple files  
NOT guessing  

ONE precise fix

────────────────────────────────

WHY YOUR SYSTEM IS ACTING LIKE THIS

Based on everything you've shown:

This is almost certainly happening:

• useEffect runs again on tab focus
OR
• stream reconnect logic fires again
OR
• interval restarts without cleanup

Result:

→ multiple streams stack  
→ guidance floods the UI again  

────────────────────────────────

WHAT YOU SHOULD EXPECT NEXT

I’m going to:

1. Inspect ONLY the selected file
2. Identify EXACT cause (no guessing)
3. Apply ONE of:
   • idempotent guard
   • cleanup fix

Then we re-test.

────────────────────────────────

STATE

STABLE  
FOCUSED  
NOT LOST  

YOU DID EVERYTHING RIGHT  

NEXT MOVE IS THE FIRST REAL BUG FIX

