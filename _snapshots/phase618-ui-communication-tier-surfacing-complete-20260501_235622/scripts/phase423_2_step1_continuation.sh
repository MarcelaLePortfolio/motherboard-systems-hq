#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUTPUT="docs/phase423_2_step1_execution_anchor_link_resolution.md"
TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT

python3 - << 'PY' > "$TMP_JSON"
import os
import re
import json
from pathlib import Path
from collections import defaultdict

ROOT = Path.cwd()
OUTPUT = ROOT / "docs" / "phase423_2_step1_execution_anchor_link_resolution.md"

EXECUTION_ANCHOR = "runConsumptionRegistryEnforcementEntrypoint"
GOVERNANCE_ANCHORS = [
    "buildGovernanceLiveRegistryWiringReadiness",
    "buildGovernanceLiveWiringDecision",
    "buildGovernanceAuthorizationGate",
    "evaluateGovernancePolicy",
]
ALL_ANCHORS = [EXECUTION_ANCHOR] + GOVERNANCE_ANCHORS

INCLUDE_EXTS = {
    ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs",
    ".mts", ".cts", ".json", ".md"
}
EXCLUDE_DIRS = {
    ".git", "node_modules", ".next", "dist", "build",
    "coverage", ".turbo", ".vercel", "tmp", "temp"
}

FUNCTION_PATTERNS = [
    re.compile(r'^\s*(?:export\s+)?(?:async\s+)?function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('),
    re.compile(r'^\s*(?:export\s+)?const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:async\s*)?\([^)]*\)\s*=>'),
    re.compile(r'^\s*(?:export\s+)?(?:let|var)\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:async\s*)?\([^)]*\)\s*=>'),
    re.compile(r'^\s*(?:export\s+)?const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:async\s*)?function\b'),
    re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*\([^)]*\)\s*\{')
]

def rel(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)

def iter_files():
    for root, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for name in files:
            p = Path(root) / name
            if p.suffix.lower() in INCLUDE_EXTS:
                yield p

def read_lines(path: Path):
    try:
        return path.read_text(encoding="utf-8", errors="ignore").splitlines()
    except Exception:
        return []

def enclosing_function(lines, line_idx, max_scan=160):
    start = max(0, line_idx - max_scan)
    for idx in range(line_idx, start - 1, -1):
        line = lines[idx]
        for pat in FUNCTION_PATTERNS:
            m = pat.search(line)
            if m:
                return m.group(1), idx + 1
    return "__TOP_LEVEL__", None

def classify_termination(path_str: str) -> str:
    lowered = path_str.lower()
    if "dashboard" in lowered or "/app/" in lowered or lowered.startswith("app/") or "/routes/" in lowered or "route" in lowered:
        return "dashboard/routes surface"
    if "operator" in lowered:
        return "operator surface"
    if "registry" in lowered:
        return "registry trigger"
    if "execution" in lowered or "routing" in lowered:
        return "execution routing layer"
    return "unclassified"

files = list(iter_files())

anchor_hits = defaultdict(list)
file_anchor_presence = defaultdict(set)
function_defs = defaultdict(list)
call_sites = defaultdict(list)

for path in files:
    lines = read_lines(path)
    path_str = rel(path)

    for idx, line in enumerate(lines):
        for pat in FUNCTION_PATTERNS:
            m = pat.search(line)
            if m:
                function_defs[m.group(1)].append({
                    "file": path_str,
                    "line": idx + 1,
                })

        for anchor in ALL_ANCHORS:
            if anchor in line:
                anchor_hits[anchor].append({
                    "file": path_str,
                    "line": idx + 1,
                    "text": line.strip(),
                })
                file_anchor_presence[path_str].add(anchor)

    joined = "\n".join(lines)
    for name in ALL_ANCHORS:
        for m in re.finditer(r'\b' + re.escape(name) + r'\s*\(', joined):
            pos = joined[:m.start()].count("\n")
            caller_name, caller_line = enclosing_function(lines, pos)
            call_sites[name].append({
                "callee": name,
                "caller": caller_name,
                "caller_line": caller_line,
                "call_line": pos + 1,
                "file": path_str,
                "termination_guess": classify_termination(path_str),
                "line_text": lines[pos].strip() if 0 <= pos < len(lines) else ""
            })

all_function_names = set(function_defs.keys())

def find_callers(name):
    results = []
    needle = re.compile(r'\b' + re.escape(name) + r'\s*\(')
    for path in files:
        lines = read_lines(path)
        path_str = rel(path)
        for idx, line in enumerate(lines):
            if needle.search(line):
                caller_name, caller_line = enclosing_function(lines, idx)
                results.append({
                    "callee": name,
                    "caller": caller_name,
                    "caller_line": caller_line,
                    "call_line": idx + 1,
                    "file": path_str,
                    "termination_guess": classify_termination(path_str),
                    "line_text": line.strip(),
                })
    deduped = []
    seen = set()
    for item in results:
        key = (item["callee"], item["caller"], item["caller_line"], item["call_line"], item["file"])
        if key not in seen:
            seen.add(key)
            deduped.append(item)
    return deduped

def build_ladder(start_names, max_depth=8):
    visited = set()
    ladder = []
    frontier = list(start_names)
    depth = 0

    while frontier and depth < max_depth:
        next_frontier = []
        layer = []
        for callee in frontier:
            callers = find_callers(callee)
            layer.append({
                "target": callee,
                "callers": callers
            })
            for c in callers:
                caller = c["caller"]
                if caller != "__TOP_LEVEL__" and caller not in visited:
                    visited.add(caller)
                    next_frontier.append(caller)
        ladder.append({
            "depth": depth,
            "entries": layer
        })
        frontier = sorted(set(next_frontier))
        depth += 1
    return ladder

execution_ladder = build_ladder([EXECUTION_ANCHOR])
governance_ladder = build_ladder(GOVERNANCE_ANCHORS)

execution_files = {hit["file"] for hit in anchor_hits[EXECUTION_ANCHOR]}
governance_files = {hit["file"] for g in GOVERNANCE_ANCHORS for hit in anchor_hits[g]}
co_located_files = sorted(execution_files & governance_files)

def ladder_nodes(ladder):
    names = set()
    files = set()
    for layer in ladder:
        for entry in layer["entries"]:
            names.add(entry["target"])
            for c in entry["callers"]:
                names.add(c["caller"])
                files.add(c["file"])
    return names, files

exec_nodes, exec_ladder_files = ladder_nodes(execution_ladder)
gov_nodes, gov_ladder_files = ladder_nodes(governance_ladder)

shared_nodes = sorted(n for n in (exec_nodes & gov_nodes) if n not in {"__TOP_LEVEL__", EXECUTION_ANCHOR, *GOVERNANCE_ANCHORS})
shared_files = sorted(exec_ladder_files & gov_ladder_files)

if shared_nodes or shared_files:
    intersection_result = "INTERSECTION DETECTED"
    deterministic_conclusion = "Execution and governance ladders intersect within the inspected deterministic topology."
elif co_located_files:
    intersection_result = "NO LADDER INTERSECTION DETECTED / CO-LOCATION ONLY"
    deterministic_conclusion = "Single-file co-location exists, but no ladder intersection was proven by this pass."
else:
    intersection_result = "NO INTERSECTION DETECTED"
    deterministic_conclusion = "Execution and governance remained separate deterministic surfaces in this pass."

result = {
    "execution_anchor": EXECUTION_ANCHOR,
    "governance_anchors": GOVERNANCE_ANCHORS,
    "anchor_hits": anchor_hits,
    "co_located_files": co_located_files,
    "execution_ladder": execution_ladder,
    "governance_ladder": governance_ladder,
    "shared_nodes": shared_nodes,
    "shared_files": shared_files,
    "intersection_result": intersection_result,
    "deterministic_conclusion": deterministic_conclusion,
    "output": str(OUTPUT),
}

print(json.dumps(result, indent=2))
PY

python3 - << 'PY' "$TMP_JSON" "$OUTPUT"
import json
import sys
from pathlib import Path

tmp_json = Path(sys.argv[1])
output = Path(sys.argv[2])
data = json.loads(tmp_json.read_text())

def format_hits(title, hits):
    lines = [f"### {title}"]
    if not hits:
        lines.append("- No hits found.")
        return "\n".join(lines)
    for hit in hits:
        lines.append(f"- `{hit['file']}:{hit['line']}` — `{hit['text']}`")
    return "\n".join(lines)

def format_ladder(title, ladder):
    lines = [f"## {title}"]
    empty = True
    for layer in ladder:
        lines.append(f"### Depth {layer['depth']}")
        for entry in layer["entries"]:
            callers = entry["callers"]
            if callers:
                empty = False
                lines.append(f"- Target: `{entry['target']}`")
                for caller in callers:
                    caller_name = caller["caller"]
                    if caller_name == "__TOP_LEVEL__":
                        rendered = f"top-level context in `{caller['file']}:{caller['call_line']}`"
                    else:
                        rendered = f"`{caller_name}` in `{caller['file']}:{caller['caller_line']}` via call at `{caller['file']}:{caller['call_line']}`"
                    lines.append(f"  - {rendered} [{caller['termination_guess']}]")
            else:
                lines.append(f"- Target: `{entry['target']}`")
                lines.append("  - No callers found.")
    if empty:
        lines.append("- No callers found in ladder.")
    return "\n".join(lines)

section = []
section.append("# Phase 423.2 — Step 1")
section.append("## Execution Anchor Hunt — Direct Link Verification Pass")
section.append("")
section.append("### Step 1.5 — Single-File Co-Location Check")
section.append("")
section.append(f"- Execution anchor: `{data['execution_anchor']}`")
section.append(f"- Governance anchors: `{', '.join(data['governance_anchors'])}`")
section.append("")
section.append(format_hits("Execution Anchor Hits", data["anchor_hits"].get(data["execution_anchor"], [])))
for anchor in data["governance_anchors"]:
    section.append("")
    section.append(format_hits(f"Governance Anchor Hits — {anchor}", data["anchor_hits"].get(anchor, [])))
section.append("")
if data["co_located_files"]:
    section.append("### Co-Location Result")
    for path in data["co_located_files"]:
        section.append(f"- `{path}`")
else:
    section.append("### Co-Location Result")
    section.append("- No direct co-location topology.")
section.append("")
section.append(format_ladder("Step 1.6 — Execution Ladder", data["execution_ladder"]))
section.append("")
section.append(format_ladder("Step 1.7 — Governance Ladder", data["governance_ladder"]))
section.append("")
section.append("## Step 1.8 — Ladder Comparison")
section.append("")
section.append(f"- Intersection result: **{data['intersection_result']}**")
if data["shared_nodes"]:
    section.append("- Shared caller nodes:")
    for node in data["shared_nodes"]:
        section.append(f"  - `{node}`")
else:
    section.append("- Shared caller nodes: none proven.")
if data["shared_files"]:
    section.append("- Shared ladder files:")
    for path in data["shared_files"]:
        section.append(f"  - `{path}`")
else:
    section.append("- Shared ladder files: none proven.")
section.append("")
section.append("## Deterministic Conclusion")
section.append(data["deterministic_conclusion"])
section.append("")

output.parent.mkdir(parents=True, exist_ok=True)

existing = ""
if output.exists():
    existing = output.read_text(encoding="utf-8", errors="ignore").rstrip() + "\n\n"

output.write_text(existing + "\n".join(section), encoding="utf-8")
PY

echo "Phase 423.2 Step 1 continuation evidence collected."
echo "Results appended to $OUTPUT"

