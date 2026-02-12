import subprocess
from pathlib import Path
import re
import sys

def sh(*args: str) -> str:
    return subprocess.check_output(list(args), text=True).strip()

ROOT = Path(sh("git", "rev-parse", "--show-toplevel"))
assert ROOT.exists()

def die(msg: str):
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(2)

def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")

def write(p: Path, s: str):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(s, encoding="utf-8")

def list_files(globs):
    out = []
    for g in globs:
        out.extend(ROOT.glob(g))
    return [p for p in out if p.is_file()]

def rg_list(needle: str, globs=None):
    files = list_files(globs or ["server/**/*.ts", "server/**/*.js"])
    hits = []
    for f in files:
        try:
            t = read(f)
        except Exception:
            continue
        if needle in t:
            hits.append(f)
    return hits

# --- 1) De-dupe migrations created by earlier failed script runs
mig_files = sorted((ROOT / "drizzle_pg").glob("*_phase39_action_tier_scaffolding.sql"))
if len(mig_files) >= 2:
    keep = mig_files[0]
    for f in mig_files[1:]:
        f.unlink()
    print(f"OK: kept {keep.relative_to(ROOT)}, deleted {len(mig_files)-1} duplicate(s)")
elif len(mig_files) == 1:
    print(f"OK: migration present {mig_files[0].relative_to(ROOT)}")
else:
    die("no phase39_action_tier_scaffolding migration found in drizzle_pg/")

# --- 2) Remove broken/one-off apply script (it is not part of Phase 39 deliverable)
apply_script = ROOT / "scripts" / "phase39_apply_action_tier_scaffolding.py"
if apply_script.exists():
    apply_script.unlink()
    print("OK: removed scripts/phase39_apply_action_tier_scaffolding.py")

# --- 3) Add worker pre-execution gate in the real worker (Tier A allowed; B/C fail-fast)
# Heuristic: find a worker-like file that calls executeTask/runTask/performTask.
candidates = []
for needle in ("executeTask(", "runTask(", "performTask("):
    candidates += rg_list(needle, ["server/**/*.ts", "server/**/*.js"])
# Prefer paths that look like worker code.
def score(p: Path) -> int:
    s = 0
    ps = str(p).lower()
    if "/worker" in ps: s += 50
    if "server/worker" in ps: s += 50
    if "worker" in p.name.lower(): s += 20
    if "task-lifecycle" in p.name.lower(): s -= 10  # not the worker
    return -s  # sort ascending

candidates = sorted(set(candidates), key=score)
if not candidates:
    die("could not locate worker file (no executeTask/runTask/performTask usage found under server/)")
worker_file = candidates[0]
w = read(worker_file)

if "ACTION_TIER_BLOCKED" in w or "Action Tier pre-execution gate" in w:
    print(f"OK: worker gate already present in {worker_file.relative_to(ROOT)}")
else:
    # Insert helper near top (after imports)
    helper = (
        "\n"
        "// Phase 39: Action Tier pre-execution gate (A allowed; B/C blocked)\n"
        "function __mbIsTierA(t: any): boolean {\n"
        "  const v = String(t ?? 'A');\n"
        "  return v === 'A';\n"
        "}\n"
    )

    lines = w.splitlines(True)
    insert_idx = 0
    for i, line in enumerate(lines[:200]):
        if line.startswith("import "):
            insert_idx = i + 1
    lines.insert(insert_idx, helper)
    w2 = "".join(lines)

    # Insert gate immediately before the first execute/run/perform call we see.
    # We capture the variable name passed to the function (best-effort).
    patterns = [
        r"(\n[ \t]*await[ \t]+executeTask\(\s*([A-Za-z0-9_]+)\s*\)\s*;)",
        r"(\n[ \t]*await[ \t]+runTask\(\s*([A-Za-z0-9_]+)\s*\)\s*;)",
        r"(\n[ \t]*await[ \t]+performTask\(\s*([A-Za-z0-9_]+)\s*\)\s*;)",
    ]
    m = None
    for pat in patterns:
        m = re.search(pat, w2)
        if m:
            break
    if not m:
        die(f"found {worker_file.relative_to(ROOT)} but could not identify an await executeTask/runTask/performTask call")

    var = m.group(2)
    gate = (
        "\n"
        "    // Phase 39: Action Tier pre-execution gate\n"
        f"    if (!__mbIsTierA(({var} as any)?.action_tier ?? ({var} as any)?.actionTier)) {{\n"
        f"      const __tier = String((({var} as any)?.action_tier ?? ({var} as any)?.actionTier) ?? '');\n"
        "      const tier = (__tier && __tier.trim()) ? __tier.trim() : 'UNKNOWN';\n"
        "      const e: any = new Error(`Blocked by action_tier gate: ${tier}`);\n"
        "      (e as any).code = 'ACTION_TIER_BLOCKED';\n"
        "      throw e;\n"
        "    }\n"
    )
    insert_at = m.start(1)
    w3 = w2[:insert_at] + gate + w2[insert_at:]
    write(worker_file, w3)
    print(f"OK: inserted worker gate into {worker_file.relative_to(ROOT)}")

