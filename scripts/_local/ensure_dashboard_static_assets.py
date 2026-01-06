#!/usr/bin/env python3
import re, sys
from pathlib import Path

def find_server_file() -> Path:
    # Prefer the file that logs "Server running on http://0.0.0.0:3000"
    # Fallback to common names.
    needles = [
        r"Server running on http://0\.0\.0\.0:3000",
        r"0\.0\.0\.0:3000",
    ]
    candidates = []
    for p in Path(".").rglob("*"):
        if not p.is_file():
            continue
        if p.suffix not in {".mjs", ".js", ".ts"}:
            continue
        if any(part in {".git", "node_modules", "dist", "build"} for part in p.parts):
            continue
        try:
            s = p.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for n in needles:
            if re.search(n, s):
                return p
        if p.name in {"server.mjs", "server.js", "server.ts"}:
            candidates.append(p)
    if candidates:
        return candidates[0]
    raise FileNotFoundError("Could not locate dashboard server file")

def main():
    p = find_server_file()
    s = p.read_text(encoding="utf-8", errors="replace")

    # If it already mounts /css and /js, bail.
    if re.search(r'app\.use\(\s*["\']/css["\']\s*,\s*express\.static', s) and re.search(r'app\.use\(\s*["\']/js["\']\s*,\s*express\.static', s):
        print(f"OK: {p} already serves /css and /js")
        return 0

    # Ensure path + __dirname helpers exist (ESM-safe)
    if "fileURLToPath" not in s:
        insert_imports = (
            'import path from "path";\n'
            'import { fileURLToPath } from "url";\n'
        )
        # Insert after the first import line
        m = re.search(r'^(import .+\n)', s, flags=re.M)
        if m:
            s = s[:m.end()] + insert_imports + s[m.end():]
        else:
            s = insert_imports + s

    if "__dirname" not in s or "fileURLToPath(import.meta.url)" not in s:
        helper = (
            "\n"
            "const __filename = fileURLToPath(import.meta.url);\n"
            "const __dirname = path.dirname(__filename);\n"
        )
        # Place helper after app creation or near top
        m = re.search(r'(const\s+app\s*=\s*express\(\)\s*;?\n)', s)
        if m:
            s = s[:m.end()] + helper + s[m.end():]
        else:
            s = helper + s

    # Insert static mounts right after app creation (or after helper if we added it)
    static_block = (
        "\n"
        "// Serve static assets from ./public (required for /css/* and /js/* on /dashboard)\n"
        "app.use(express.static(path.join(__dirname, \"public\")));\n"
        "app.use(\"/css\", express.static(path.join(__dirname, \"public\", \"css\")));\n"
        "app.use(\"/js\", express.static(path.join(__dirname, \"public\", \"js\")));\n"
        "app.use(\"/img\", express.static(path.join(__dirname, \"public\", \"img\")));\n"
    )

    # Avoid duplicate insertion
    if "Serve static assets from ./public" not in s:
        m = re.search(r'(const\s+app\s*=\s*express\(\)\s*;?\n(?:const __filename.*\nconst __dirname.*\n)?)', s)
        if m:
            s = s[:m.end()] + static_block + s[m.end():]
        else:
            # last resort: append near top
            s = static_block + s

    p.write_text(s, encoding="utf-8")
    print(f"PATCHED: {p} (added static mounts for /css /js /img from public/)")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
