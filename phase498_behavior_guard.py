from pathlib import Path

p = Path("server.mjs")
text = p.read_text()

anchor = "const finalReply = ollamaReply || deterministicReply;"

if anchor not in text:
    raise SystemExit("Anchor not found. STOP.")

injection = '''const finalReplyRaw = ollamaReply || deterministicReply;

    // PHASE498: Behavior contract hardening (no implied execution authority)
    const finalReply = finalReplyRaw
      .replace(/\\b(it is executable|this will execute|i will execute|executing now)\\b/gi, "this appears ready")
      .replace(/\\b(yes, it is executable)\\b/gi, "this appears ready based on current state")
      .replace(/\\b(i can execute this)\\b/gi, "this can be executed through the proper system pathway");'''

text = text.replace(anchor, injection)

p.write_text(text)
