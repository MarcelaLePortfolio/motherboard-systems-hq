#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

REPORT="docs/phase423_2_step1_execution_anchor_link_resolution.md"

python3 <<'PY'
import re
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
    ".yml", ".yaml", ".sql", ".txt", ".env", ".css", ".scss", ".html", ".py"
}
EXCLUDED_GENERATED_PATH_PATTERNS = [
    re.compile(r"^docs/phase423_2_step1_.*"),
    re.compile(r"^scripts/_local/phase423_2_step1_continuation\.sh$"),
]
DEF_PATTERNS = [
    re.compile(r'^\s*export\s+(?:async\s+)?function\s+([A-Za-z_]\w*)\s*\('),
    re.compile(r'^\s*(?:async\s+)?function\s+([A-Za-z_]\w*)\s*\('),
    re.compile(r'^\s*export\s+const\s+([A-Za-z_]\w*)\s*=\s*(?:async\s*)?\('),
    re.compile(r'^\s*const\s+([A-Za-z_]\w*)\s*=\s*(?:async\s*)?\('),
    re.compile(r'^\s*export\s+const\s+([A-Za-z_]\w*)\s*=\s*(?:async\s*)?[^=]*=>'),
    re.compile(r'^\s*const\s+([A-Za-z_]\w*)\s*=\s*(?:async\s*)?[^=]*=>'),
]
ROOT_SURFACE_HINTS = [
    "app/", "pages/", "src/app/", "src/pages/", "route.ts", "routes/", "router/",
    "dashboard", "operator", "registry", "trigger", "execution", "surface",
]

def is_excluded_generated_path(rel_path: str) -> bool:
    return any(p.search(rel_path) for p in EXCLUDED_GENERATED_PATH_PATTERNS)

def should_skip(path: Path) -> bool:
    rel = path.relative_to(ROOT).as_posix()
    if is_excluded_generated_path(rel):
        return True
    if any(part in SKIP_DIRS for part in path.parts):
        return True
    if path.is_dir():
        return False
    if path.suffix.lower() in TEXT_EXTS:
        return False
    try:
        return path.stat().st_size > 1_500_000
    except Exception:
        return True

def iter_files(root: Path):
    for p in root.rglob("*"):
        if should_skip(p):
            continue
        if p.is_file():
            yield p

def read_lines(path: Path):
    try:
        return path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except Exception:
        return []

files = list(iter_files(ROOT))
all_lines = {}
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
                defs.append((i, m.group(1)))
                break
        for name in matches:
            if name in line:
                matches[name].append({"file": rel, "line": i, "text": line.strip()})
    file_defs[rel] = defs

def enclosing_function(file_path: str, line_no: int):
    candidate = None
    for ln, fn in file_defs.get(file_path, []):
        if ln <= line_no:
            candidate = (fn, ln)
        else:
            break
    if candidate:
        return {"function": candidate[0], "defined_at_line": candidate[1]}
    return None

def find_calls(target: str):
    needle = f"{target}("
    out = []
    for file_path, lines in all_lines.items():
        for i, line in enumerate(lines, start=1):
            if needle in line:
                inside = enclosing_function(file_path, i)
                is_definition = (
                    re.search(rf'\bfunction\s+{re.escape(target)}\s*\(', line) is not None
                    or re.search(rf'\bconst\s+{re.escape(target)}\b', line) is not None
                )
                out.append({
                    "target": target,
                    "file": file_path,
                    "line": i,
                    "text": line.strip(),
                    "inside_function": inside["function"] if inside else None,
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

def flatten_ladder(ladder):
    funcs = set()
    files_seen = set()
    roots = []
    for level in ladder:
        for c in level["calls"]:
            caller = c["inside_function"] or "<top-level>"
            funcs.add(caller)
            files_seen.add(c["file"])
            if c["inside_function"] is None or any(h in c["file"] for h in ROOT_SURFACE_HINTS):
                roots.append({
                    "target": c["target"],
                    "caller": caller,
                    "file": c["file"],
                    "line": c["line"],
                    "text": c["text"],
                })
    return funcs, files_seen, roots

exec_ladder = expand_ladder([EXECUTION])
gov_ladder = expand_ladder(GOVERNANCE)

exec_files = {m["file"] for m in matches[EXECUTION]}
gov_files = {m["file"] for name in GOVERNANCE for m in matches[name]}
co_located = sorted(exec_files & gov_files)

exec_funcs, exec_ladder_files, exec_roots = flatten_ladder(exec_ladder)
gov_funcs, gov_ladder_files, gov_roots = flatten_ladder(gov_ladder)

func_intersection = sorted((exec_funcs & gov_funcs) - {"<top-level>"})
file_intersection = sorted(exec_ladder_files & gov_ladder_files)
topology_intersection = sorted(set(co_located) | set(file_intersection))

if func_intersection or file_intersection:
    case = "CASE A/B — intersection present"
    conclusion = "Integrated governed execution evidence detected: execution and governance ladders intersect."
else:
    case = "CASE C — no intersection"
    conclusion = "No execution/governance ladder intersection detected in this pass. Surfaces remain separate in currently observed topology."

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

## Scope control

Excluded generated self-reference surfaces from this pass:

- `docs/phase423_2_step1_*`
- `scripts/_local/phase423_2_step1_continuation.sh`

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
Generated proof artifacts were excluded from topology comparison to prevent self-referential contamination.
No runtime mutation performed.
No architecture changes performed.
No fix proposals included.
"""

REPORT.parent.mkdir(parents=True, exist_ok=True)
REPORT.write_text(content, encoding="utf-8")
print(f"Wrote {REPORT}")
PY

printf '\nGenerated report: %s\n' "$REPORT"
