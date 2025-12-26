#!/usr/bin/env python3
import pathlib, re, sys

CANDIDATES = ["Dockerfile.dashboard", "Dockerfile"]

def ensure_copy_public(path: pathlib.Path) -> bool:
    if not path.exists():
        return False

    s = path.read_text(encoding="utf-8", errors="replace")

    # Already good?
    if re.search(r'^\s*COPY\s+public/?\s+(\./)?public/?\s*$', s, flags=re.M):
        print(f"OK: {path} already has: COPY public ./public")
        return True

    # Remove any narrow public copies and replace with a full-tree copy
    lines = s.splitlines(True)
    new_lines = []
    removed = 0
    for ln in lines:
        if re.match(r'^\s*(COPY|ADD)\s+public/.*\s+(\./)?public/.*\s*$', ln):
            removed += 1
            continue
        new_lines.append(ln)

    s2 = "".join(new_lines)
    insert_line = "COPY public/ ./public/\n"

    # Insert before CMD/ENTRYPOINT if present
    m = re.search(r'^\s*(CMD|ENTRYPOINT)\b', s2, flags=re.M)
    if m:
        idx = m.start()
        s2 = s2[:idx] + insert_line + s2[idx:]
    else:
        if not s2.endswith("\n"):
            s2 += "\n"
        s2 += insert_line

    path.write_text(s2, encoding="utf-8")
    print(f"PATCHED: {path} (removed {removed} narrow public copy line(s); added COPY public/ ./public/)")
    return True

hit = False
for name in CANDIDATES:
    if ensure_copy_public(pathlib.Path(name)):
        hit = True

if not hit:
    print("ERROR: No Dockerfile.dashboard or Dockerfile found.", file=sys.stderr)
    sys.exit(2)
