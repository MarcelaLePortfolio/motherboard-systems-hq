#!/usr/bin/env bash
set -euo pipefail

REPORT="docs/phase423_2_step1_execution_anchor_link_resolution.md"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

python3 <<'PY'
import os
import re
import json
from pathlib import Path
from datetime import datetime, timezone

ROOT = Path(".").resolve()
REPORT = ROOT / "docs/phase423_2_step1_execution_anchor_link_resolution.md"

EXECUTION = "runConsumptionRegistryEnforcementEntrypoint"
GOVERNANCE = [
    "buildGovernanceLiveRegistryWiringReadiness",
    "buildGovernanceLiveWiringDecision",
    "buildGovernanceAuthorizationGate",
    "evaluateGovernancePolicy",
]

SKIP_DIRS = {
    ".git", "node_modules", ".next", "dist", "build", "coverage", ".turbo",
    ".vercel", "vendor", "__pycache__", ".pnpm-store", ".idea", ".vscode"
}
TEXT_EXTS = {
    ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".json", ".md", ".sh",
    ".yml", ".yaml", ".sql", ".txt", ".env", ".css", ".scss", ".html"
}
DEF_PATTERNS = [
    re.compile(r'^\s*export\s+(?:async\s+)?function\s+([A-Za-z_]\w*)\s*\('),
    re.compile(r'^\s*(?:async\s+)?function\s+([A-Za-z_]\w*)\s*\('),
    re.compile(r'^\s*export\s+const\s+([A-Za-z_]\w*)\s*=\s*(?:async\s*)?\('),
    re.compile(r'^\s*const\s+([A-Za-z_]\w*)\s*=\s*(?:async\s*)?\('),
    re.compile(r'^\s*export\s+const\s+([A-Za-z_]\w*)\s*=\s*(?:async\s*)?[^=]*=>'),
    re.compile(r'^\s*const\s+([A-Za-z_]\w*)\s*=\s*(?:async\s*)?[^=]*=>'),
    re.compile(r'^\s*export\s+async\s+function\s+([A-Za-z_]\w*)\s*\('),
]
ROOT_SURFACE_HINTS = [
    "app/", "pages/", "src/app/", "src/pages/", "route.ts", "routes/", "router/",
    "dashboard", "operator", "registry", "trigger", "execution", "surface",
]

def should_skip(path: Path) -> bool:
    parts = set(path.parts)
    if parts & SKIP_DIRS:
        return True
    if path.is_dir():
        return False
    if path.suffix.lower() in TEXT_EXTS:
        return False
    try:
        if path.stat().st_size > 1_500_000:
            return True
    except Exception:
        return True
    return False

def iter_files(root: Path):
    for p in root.rglob("*"):
        if should_skip(p):
            continue
        if p.is_file():
            yield p

def read_lines(path: Path):
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
        return text.splitlines()
    except Exception:
        return []

files = list(iter_files(ROOT))
all_lines = {}
definitions = {}
file_defs = {}
matches = {name: [] for name in [EXECUTION] + GOVERNANCE}

for f in files:
    rel = f.relative_to(ROOT).as_posix()
    lines = read_lines(f)
    all_lines[rel] = lines
    defs = []
    for i, line in enumerate(lines, start=1):
        for pat in DEF_PATTERNS:
            m = pat.search(line)
            if m:
                fn = m.group(1)
                defs.append((i, fn))
                definitions.setdefault(fn, []).append({"file": rel, "line": i})
                break
        for name in matches:
            if name in line:
                matches[name].append({"file": rel, "line": i, "text": line.strip()})
    file_defs[rel] = defs

def enclosing_function(file: str, line_no: int):
    defs = file_defs.get(file, [])
    candidate = None
    for ln, fn in defs:
        if ln <= line_no:
            candidate = (fn, ln)
        else:
            break
    if candidate:
        return {"function": candidate[0], "defined_at_line": candidate[1]}
    return None

def find_calls(target: str):
    out = []
    needle = f"{target}("
    for file, lines in all_lines.items():
        for i, line in enumerate(lines, start=1):
            if needle in line:
                inside = enclosing_function(file, i)
                is_definition = bool(re.search(rf'\bfunction\s+{re.escape(target)}\s*\(', line)) or bool(re.search(rf'\bconst\s+{re.escape(target)}\b', line))
                out.append({
                    "target": target,
                    "file": file,
                    "line": i,
                    "text": line.strip(),
                    "inside_function": inside["function"] if inside else None,
                    "inside_function_line": inside["defined_at_line"] if inside else None,
                    "is_definition_line": is_definition,
                })
    return out

def expand_ladder(seed_targets, max_depth=8):
    visited_targets = set()
    ladder = []
    frontier = list(seed_targets)
    depth = 0

    while frontier and depth < max_depth:
        next_frontier = []
        for target in frontier:
            if target in visited_targets:
                continue
            visited_targets.add(target)
            calls = find_calls(target)
            meaningful = []
            for c in calls:
                if c["inside_function"] is None or not c["is_definition_line"] or any(h in c["file"] for h in ROOT_SURFACE_HINTS):
                    meaningful.append(c)
            ladder.append({"target": target, "calls": meaningful})
            for c in meaningful:
                caller = c["inside_function"]
                if caller and caller not in visited_targets and caller not in frontier and caller not in next_frontier:
                    next_frontier.append(caller)
        frontier = next_frontier
        depth += 1
    return ladder

exec_ladder = expand_ladder([EXECUTION])
gov_ladder = expand_ladder(GOVERNANCE)

exec_files = {m["file"] for m in matches[EXECUTION]}
gov_files = {m["file"] for name in GOVERNANCE for m in matches[name]}
co_located = sorted(exec_files & gov_files)

def flatten_ladder(ladder):
    rows = []
    funcs = set()
    files = set()
    roots = []
    for level in ladder:
        target = level["target"]
        for c in level["calls"]:
            caller = c["inside_function"] or "<top-level>"
            key = f"{caller} @ {c['file']}"
            rows.append({
                "target": target,
                "caller": caller,
                "file": c["file"],
                "line": c["line"],
                "text": c["text"],
                "key": key,
            })
            funcs.add(caller)
            files.add(c["file"])
            if c["inside_function"] is None or any(h in c["file"] for h in ROOT_SURFACE_HINTS):
                roots.append({
                    "target": target,
                    "caller": caller,
                    "file": c["file"],
                    "line": c["line"],
                    "text": c["text"],
                })
    return rows, funcs, files, roots

exec_rows, exec_funcs, exec_ladder_files, exec_roots = flatten_ladder(exec_ladder)
gov_rows, gov_funcs, gov_ladder_files, gov_roots = flatten_ladder(gov_ladder)

func_intersection = sorted((exec_funcs & gov_funcs) - {"<top-level>"})
file_intersection = sorted(exec_ladder_files & gov_ladder_files)
topology_intersection = sorted(set(co_located) | set(file_intersection))

if func_intersection or file_intersection:
    conclusion = "Integrated governed execution evidence detected: execution and governance ladders intersect."
    case = "CASE A/B — intersection present"
else:
    conclusion = "No execution/governance ladder intersection detected in this pass. Surfaces remain separate in currently observed topology."
    case = "CASE C — no intersection"

timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

def fmt_matches(name):
    items = matches[name]
    if not items:
        return "- No matches found."
    return "\n".join(
        f"- `{m['file']}:{m['line']}` — `{m['text']}`"
        for m in items[:200]
    )

def fmt_ladder(title, ladder, roots):
    lines = [f"### {title}", ""]
    if not ladder:
        lines.append("- No ladder entries found.")
        lines.append("")
        return "\n".join(lines)
    for level in ladder:
        lines.append(f"- Target: `{level['target']}`")
        if not level["calls"]:
            lines.append("  - No callers found.")
            continue
        for c in level["calls"][:200]:
            caller = c["inside_function"] or "<top-level>"
            lines.append(f"  - `{caller}` → `{c['target']}` at `{c['file']}:{c['line']}`")
    lines.append("")
    lines.append(f"### {title} root-surface candidates")
    lines.append("")
    if not roots:
        lines.append("- No root-surface candidates found.")
    else:
        for r in roots[:200]:
            lines.append(f"- `{r['caller']}` via `{r['file']}:{r['line']}` → `{r['text']}`")
    lines.append("")
    return "\n".join(lines)

content = f"""# Phase 423.2 — Step 1 Continuation
Execution Anchor Hunt — Direct Link Verification Pass

Updated: {timestamp}

## Step 1.5 — Single-file co-location check

### Execution anchor matches

{fmt_matches(EXECUTION)}

### Governance anchor matches

#### `buildGovernanceLiveRegistryWiringReadiness`

{fmt_matches("buildGovernanceLiveRegistryWiringReadiness")}

#### `buildGovernanceLiveWiringDecision`

{fmt_matches("buildGovernanceLiveWiringDecision")}

#### `buildGovernanceAuthorizationGate`

{fmt_matches("buildGovernanceAuthorizationGate")}

#### `evaluateGovernancePolicy`

{fmt_matches("evaluateGovernancePolicy")}

### Direct co-location result

"""
if co_located:
    content += "\n".join(f"- `{p}`" for p in co_located)
    content += "\n\nDeterministic finding: execution and governance anchors are co-located in the file paths above.\n"
else:
    content += "- No direct co-location detected.\n\nDeterministic finding: **no direct co-location topology** detected for the searched anchors.\n"

content += "\n## Step 1.6 — Execution call stack trace\n\n"
content += fmt_ladder("Execution ladder", exec_ladder, exec_roots)

content += "\n## Step 1.7 — Governance call stack trace\n\n"
content += fmt_ladder("Governance ladder", gov_ladder, gov_roots)

content += f"""
## Step 1.8 — Ladder comparison

### Function-level intersections

"""
if func_intersection:
    content += "\n".join(f"- `{x}`" for x in func_intersection) + "\n"
else:
    content += "- None detected.\n"

content += """
### File-level intersections

"""
if file_intersection:
    content += "\n".join(f"- `{x}`" for x in file_intersection) + "\n"
else:
    content += "- None detected.\n"

content += f"""
### Intersection result

- Classification: **{case}**
- Combined intersecting topology surfaces:
"""
if topology_intersection:
    content += "\n".join(f"  - `{x}`" for x in topology_intersection) + "\n"
else:
    content += "  - None detected.\n"

content += f"""
## Deterministic conclusion

{conclusion}

## Boundary note

This document records topology evidence only.
No runtime mutation performed.
No architecture changes performed.
No fix proposals included.
"""

REPORT.parent.mkdir(parents=True, exist_ok=True)
REPORT.write_text(content, encoding="utf-8")
print(f"Wrote {REPORT}")
PY

printf '\nGenerated report: %s\n' "$REPORT"
