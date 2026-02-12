import os, re, sys
from pathlib import Path

ROOT = Path(os.popen("git rev-parse --show-toplevel)").read().strip())
if not ROOT.exists():
    ROOT = Path(os.popen("git rev-parse --show-toplevel").read().strip())
assert ROOT.exists()

def die(msg: str):
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(2)

def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")

def write(p: Path, s: str):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(s, encoding="utf-8")

def find_one(patterns):
    for pat in patterns:
        hits = list(ROOT.glob(pat))
        if hits:
            return hits[0]
    return None

def rg_one(needles, globs=None):
    if globs is None:
        globs = [
            "server/**/*.ts", "server/**/*.js",
            "src/**/*.ts", "src/**/*.js",
            "app/**/*.ts", "app/**/*.js",
            "scripts/**/*.ts", "scripts/**/*.js",
        ]
    files = []
    for g in globs:
        files.extend(ROOT.glob(g))
    for f in files:
        try:
            txt = read(f)
        except Exception:
            continue
        if any(n in txt for n in needles):
            return f
    return None

# 1) PG migration: drizzle_pg/000X_phase39_action_tier_scaffolding.sql
drizzle_pg = ROOT / "drizzle_pg"
if not drizzle_pg.exists():
    die("drizzle_pg/ not found at repo root")

sql_files = sorted(drizzle_pg.glob("*.sql"))
nums = []
for f in sql_files:
    m = re.match(r"^(\d+)_", f.name)
    if m:
        nums.append(int(m.group(1)))
next_num = (max(nums) + 1) if nums else 1
mig_name = f"{next_num:04d}_phase39_action_tier_scaffolding.sql"
mig_path = drizzle_pg / mig_name

migration_sql = """\
-- Phase 39: Action Tier scaffolding (structural value-alignment)
-- Adds tasks.action_tier (default 'A') and optional disclosure fields.
-- No UI changes. Existing flows remain Tier A.

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS action_tier TEXT NOT NULL DEFAULT 'A';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'tasks_action_tier_allowed'
  ) THEN
    ALTER TABLE tasks
      ADD CONSTRAINT tasks_action_tier_allowed
      CHECK (action_tier IN ('A','B','C'));
  END IF;
END $$;

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS tier_disclosure_title TEXT,
  ADD COLUMN IF NOT EXISTS tier_disclosure_body  TEXT;

-- Disclosure validation is enforced at API boundary for B/C to avoid breaking inserts.
"""
write(mig_path, migration_sql)

# 2) Patch Drizzle schema for tasks (best-effort)
schema_file = rg_one(["export const tasks", "pgTable", "tasks ="])
if schema_file is None:
    schema_file = find_one(["server/db/schema.ts", "src/db/schema.ts", "db/schema.ts"])

if schema_file is not None:
    txt = read(schema_file)
    if "action_tier" not in txt and "actionTier" not in txt:
        m = re.search(r"(export\s+const\s+tasks\s*=\s*\w*Table\(\s*['\"]tasks['\"]\s*,\s*\{\n)", txt)
        if not m:
            m = re.search(r"(export\s+const\s+tasks\s*=\s*\w*Table\(\s*['\"]tasks['\"]\s*,\s*\{)", txt)
        if m:
            insert_at = m.end(1) if m.lastindex == 1 else m.end(0)
            col_block = (
                "  // Phase 39: action tier scaffolding\n"
                "  actionTier: text('action_tier').notNull().default('A'),\n"
                "  tierDisclosureTitle: text('tier_disclosure_title'),\n"
                "  tierDisclosureBody: text('tier_disclosure_body'),\n"
            )
            txt = txt[:insert_at] + col_block + txt[insert_at:]
            write(schema_file, txt)

# 3) Patch API task-create validation (best-effort)
api_file = rg_one(["/api/tasks", "router.post", "req.body", "tasks", "create"])
if api_file is not None:
    txt = read(api_file)

    if "Phase 39: Action Tier scaffolding" not in txt:
        lines = txt.splitlines(True)
        insert_idx = 0
        for i, line in enumerate(lines[:80]):
            if line.startswith("import "):
                insert_idx = i + 1
        helper = (
            "\n"
            "// Phase 39: Action Tier scaffolding\n"
            "const __mbActionTierAllowed = new Set(['A','B','C']);\n"
            "function __mbNormalizeActionTier(tier: any): 'A'|'B'|'C' {\n"
            "  const t = (tier ?? 'A');\n"
            "  if (!__mbActionTierAllowed.has(String(t))) return 'A';\n"
            "  return String(t) as any;\n"
            "}\n"
            "function __mbRequireDisclosureIfBC(tier: 'A'|'B'|'C', title: any, body: any) {\n"
            "  if (tier === 'A') return;\n"
            "  const t = String(title ?? '').trim();\n"
            "  const b = String(body ?? '').trim();\n"
            "  if (!t || !b) {\n"
            "    const err: any = new Error('Tier B/C requires tier_disclosure_title and tier_disclosure_body');\n"
            "    err.statusCode = 400;\n"
            "    throw err;\n"
            "  }\n"
            "}\n"
        )
        lines.insert(insert_idx, helper)
        txt = "".join(lines)

    # Insert normalization/check near req.body usage
    if "__mbNormalizeActionTier" in txt and "__mbRequireDisclosureIfBC" in txt and "tier_disclosure_title" not in txt:
        m = re.search(r"(const\s+body\s*=\s*req\.body[^\n]*\n)", txt)
        if not m:
            m = re.search(r"(const\s+\{\s*[^}]*\}\s*=\s*req\.body[^\n]*\n)", txt)
        if m:
            ins = (
                "  // Phase 39: default Tier A; validate disclosure fields for B/C\n"
                "  const actionTier = __mbNormalizeActionTier((req as any).body?.action_tier ?? (req as any).body?.actionTier);\n"
                "  const tierDisclosureTitle = (req as any).body?.tier_disclosure_title ?? (req as any).body?.tierDisclosureTitle;\n"
                "  const tierDisclosureBody  = (req as any).body?.tier_disclosure_body  ?? (req as any).body?.tierDisclosureBody;\n"
                "  __mbRequireDisclosureIfBC(actionTier, tierDisclosureTitle, tierDisclosureBody);\n"
            )
            insert_at = m.end(1)
            txt = txt[:insert_at] + ins + txt[insert_at:]

    write(api_file, txt)

# 4) Patch worker pre-execution gate (A allowed; B/C fail-fast)
worker_file = rg_one(["server/worker", "executeTask(", "runTask(", "performTask(", "claim"])
if worker_file is None:
    worker_file = find_one(["server/worker/index.ts", "server/worker/worker.ts", "server/worker.ts"])
if worker_file is None:
    die("could not locate worker file to add pre-execution gate")

w = read(worker_file)

if "Phase 39: Action Tier pre-execution gate" not in w:
    lines = w.splitlines(True)
    insert_idx = 0
    for i, line in enumerate(lines[:120]):
        if line.startswith("import "):
            insert_idx = i + 1
    gate_helper = (
        "\n"
        "// Phase 39: Action Tier pre-execution gate (A allowed; B/C blocked)\n"
        "function __mbIsTierA(t: any): boolean {\n"
        "  const v = String(t ?? 'A');\n"
        "  return v === 'A';\n"
        "}\n"
    )
    lines.insert(insert_idx, gate_helper)
    w = "".join(lines)

    # Gate insertion: before likely execution call
    patterns = [
        r"\n(\s*await\s+executeTask\(\s*([a-zA-Z0-9_]+)\s*\)\s*;)",
        r"\n(\s*await\s+runTask\(\s*([a-zA-Z0-9_]+)\s*\)\s*;)",
        r"\n(\s*await\s+performTask\(\s*([a-zA-Z0-9_]+)\s*\)\s*;)",
    ]
    inserted = False
    for pat in patterns:
        m = re.search(pat, w)
        if m:
            var = m.group(2)
            gate = (
                "\n    // Phase 39: Action Tier pre-execution gate\n"
                f"    if (!__mbIsTierA(({var} as any)?.action_tier ?? ({var} as any)?.actionTier)) {{\n"
                f"      const __tier = String((({var} as any)?.action_tier ?? ({var} as any)?.actionTier) ?? '');\n"
                "      const tier = (__tier && __tier.trim()) ? __tier.trim() : 'UNKNOWN';\n"
                "      const e: any = new Error(`Blocked by action_tier gate: ${tier}`);\n"
                "      (e as any).code = 'ACTION_TIER_BLOCKED';\n"
                "      throw e;\n"
                "    }\n"
            )
            insert_at = m.start(1)
            w = w[:insert_at] + gate + w[insert_at:]
            inserted = True
            break

    if not inserted:
        m = re.search(r"\n(\s*const\s+task\s*=\s*[^\n]+;\n)", w)
        if m:
            gate = (
                "\n  // Phase 39: Action Tier pre-execution gate\n"
                "  if (!__mbIsTierA((task as any)?.action_tier ?? (task as any)?.actionTier)) {\n"
                "    const __tier = String(((task as any)?.action_tier ?? (task as any)?.actionTier) ?? '');\n"
                "    const tier = (__tier && __tier.trim()) ? __tier.trim() : 'UNKNOWN';\n"
                "    const e: any = new Error(`Blocked by action_tier gate: ${tier}`);\n"
                "    (e as any).code = 'ACTION_TIER_BLOCKED';\n"
                "    throw e;\n"
                "  }\n"
            )
            insert_at = m.end(1)
            w = w[:insert_at] + gate + w[insert_at:]
            inserted = True

    if not inserted:
        die(f"could not find a safe insertion point for worker gate in {worker_file}")

    write(worker_file, w)

print(f"OK: wrote migration {mig_path.relative_to(ROOT)}")
print(f"OK: worker gate patched in {worker_file.relative_to(ROOT)}")
if schema_file is not None:
    print(f"OK: schema patched in {Path(schema_file).relative_to(ROOT)}")
if api_file is not None:
    print(f"OK: api validation attempted in {Path(api_file).relative_to(ROOT)}")
