import re, sys, subprocess
from pathlib import Path

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

def scan_files(globs):
    out = []
    for g in globs:
        out.extend(ROOT.glob(g))
    return [p for p in out if p.is_file()]

def score(p: Path) -> int:
    s = 0
    ps = str(p).lower()
    if "server/worker" in ps: s += 200
    if "/worker" in ps: s += 120
    if "worker" in p.name.lower(): s += 80
    if "loop" in p.name.lower(): s += 30
    if "task-lifecycle" in p.name.lower(): s -= 50
    return s

# Candidate worker files: look for claim SQL references first
needles = [
    "phase32_claim_one.sql",
    "claim_one.sql",
    "claimOne",
    "claim_one",
    "lease_expires_at",
    "lease_epoch",
]
cands = []
for f in scan_files(["server/**/*.ts", "server/**/*.js", "server/**/*.mjs", "server/**/*.cjs"]):
    try:
        t = read(f)
    except Exception:
        continue
    if any(n in t for n in needles):
        cands.append(f)

# Fallback: broader worker-ish search if nothing found
if not cands:
    for f in scan_files(["server/**/*.ts", "server/**/*.js", "server/**/*.mjs", "server/**/*.cjs"]):
        try:
            t = read(f)
        except Exception:
            continue
        if ("sleep" in t or "setInterval" in t or "poll" in t) and ("task" in t and "worker" in str(f).lower()):
            cands.append(f)

cands = sorted(set(cands), key=lambda p: (-score(p), str(p)))

if not cands:
    die("could not find worker candidate file under server/ (no claim_one/worker loop signals)")

worker_file = cands[0]
w = read(worker_file)

if "ACTION_TIER_BLOCKED" in w or "Action Tier pre-execution gate" in w:
    print(f"OK: worker gate already present in {worker_file.relative_to(ROOT)}")
    sys.exit(0)

helper = (
    "\n"
    "// Phase 39: Action Tier pre-execution gate (A allowed; B/C blocked)\n"
    "function __mbIsTierA(t: any): boolean {\n"
    "  const v = String(t ?? 'A');\n"
    "  return v === 'A';\n"
    "}\n"
)

# Insert helper after imports (or near top)
lines = w.splitlines(True)
ins_idx = 0
for i, line in enumerate(lines[:250]):
    if line.startswith("import "):
        ins_idx = i + 1
lines.insert(ins_idx, helper)
w2 = "".join(lines)

# Insert gate near a concrete "task object" usage:
# Prefer after a `const task = ...` assignment.
task_assign = re.search(r"\n([ \t]*const[ \t]+task[ \t]*=[^\n]*\n)", w2)
if task_assign:
    insert_at = task_assign.end(1)
    gate = (
        "\n"
        "  // Phase 39: Action Tier pre-execution gate\n"
        "  if (!__mbIsTierA((task as any)?.action_tier ?? (task as any)?.actionTier)) {\n"
        "    const __tier = String(((task as any)?.action_tier ?? (task as any)?.actionTier) ?? '');\n"
        "    const tier = (__tier && __tier.trim()) ? __tier.trim() : 'UNKNOWN';\n"
        "    const e: any = new Error(`Blocked by action_tier gate: ${tier}`);\n"
        "    (e as any).code = 'ACTION_TIER_BLOCKED';\n"
        "    throw e;\n"
        "  }\n"
    )
    w3 = w2[:insert_at] + gate + w2[insert_at:]
    write(worker_file, w3)
    print(f"OK: inserted worker gate after `const task = ...` in {worker_file.relative_to(ROOT)}")
    sys.exit(0)

# Fallback: after first query row assignment (row/rows[0])
row_assign = re.search(r"\n([ \t]*const[ \t]+(row|r)[ \t]*=[^\n]*\n)", w2)
if row_assign:
    var = row_assign.group(2)
    insert_at = row_assign.end(1)
    gate = (
        "\n"
        "  // Phase 39: Action Tier pre-execution gate\n"
        f"  if (!__mbIsTierA(({var} as any)?.action_tier ?? ({var} as any)?.actionTier)) {{\n"
        f"    const __tier = String((({var} as any)?.action_tier ?? ({var} as any)?.actionTier) ?? '');\n"
        "    const tier = (__tier && __tier.trim()) ? __tier.trim() : 'UNKNOWN';\n"
        "    const e: any = new Error(`Blocked by action_tier gate: ${tier}`);\n"
        "    (e as any).code = 'ACTION_TIER_BLOCKED';\n"
        "    throw e;\n"
        "  }\n"
    )
    w3 = w2[:insert_at] + gate + w2[insert_at:]
    write(worker_file, w3)
    print(f"OK: inserted worker gate after `const {var} = ...` in {worker_file.relative_to(ROOT)}")
    sys.exit(0)

# If we still can't place it, dump candidate list for manual targeting.
print("ERROR: found worker candidate file but could not find task/row assignment insertion point.")
print(f"Chosen: {worker_file.relative_to(ROOT)}")
print("Top candidates:")
for p in cands[:12]:
    print(f" - {p.relative_to(ROOT)}")
sys.exit(2)
