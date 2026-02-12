from __future__ import annotations
from pathlib import Path
import re, sys
HELPER = """
// PHASE39_ACTION_TIER: structural value-alignment scaffolding (A default; B/C require disclosures)
function __mbNormalizeTier(x) {
  const v = String(x ?? 'A').trim().toUpperCase();
  return (v === 'B' || v === 'C') ? v : 'A';
}
function __mbRequireDisclosureIfBC(tier, title, body) {
  if (tier === 'A') return;
  const t = String(title ?? '').trim();
  const b = String(body ?? '').trim();
  if (!t || !b) {
    const err = new Error('Tier B/C requires tier_disclosure_title and tier_disclosure_body');
    err.code = 'TIER_DISCLOSURE_REQUIRED';
    throw err;
  }
}
""".lstrip("\n")
def patch_file(p: Path) -> bool:
  s = p.read_text()

  if "PHASE39_ACTION_TIER" not in s:
    # insert helper after imports (best-effort)
    lines = s.splitlines(True)
    ins = 0
    for i, line in enumerate(lines[:260]):
      if line.lstrip().startswith("import "):
        ins = i + 1
    lines.insert(ins, HELPER + "\n")
    s = "".join(lines)

  # 1) ensure we compute tier fields from taskSpec/body and validate
  if "__mbNormalizeTier" in s and "__action_tier" not in s:
    # preferred: taskSpec exists
    m = re.search(r"\bconst\s+taskSpec\s*=\s*[^;]+;\s*", s)
    if m:
      inject = (
        "\n  // PHASE39_ACTION_TIER\n"
        "  const __action_tier = __mbNormalizeTier(taskSpec?.action_tier ?? taskSpec?.actionTier);\n"
        "  const __tier_disclosure_title = taskSpec?.tier_disclosure_title ?? taskSpec?.tierDisclosureTitle;\n"
        "  const __tier_disclosure_body  = taskSpec?.tier_disclosure_body  ?? taskSpec?.tierDisclosureBody;\n"
        "  __mbRequireDisclosureIfBC(__action_tier, __tier_disclosure_title, __tier_disclosure_body);\n"
      )
      s = s[:m.end()] + inject + s[m.end():]
    else:
      # fallback: body exists
      m2 = re.search(r"\bconst\s+body\s*=\s*req\.body\s*\?\?\s*\{\s*\}\s*;\s*", s)
      if m2:
        inject = (
          "\n  // PHASE39_ACTION_TIER\n"
          "  const __action_tier = __mbNormalizeTier(body?.action_tier ?? body?.actionTier);\n"
          "  const __tier_disclosure_title = body?.tier_disclosure_title ?? body?.tierDisclosureTitle;\n"
          "  const __tier_disclosure_body  = body?.tier_disclosure_body  ?? body?.tierDisclosureBody;\n"
          "  __mbRequireDisclosureIfBC(__action_tier, __tier_disclosure_title, __tier_disclosure_body);\n"
        )
        s = s[:m2.end()] + inject + s[m2.end():]

  # 2) patch dbDelegateTask call args to include the new columns
  # match: await dbDelegateTask(db, { ... });
  def inject_into_obj(obj_text: str) -> str:
    if re.search(r"\baction_tier\b", obj_text):
      return obj_text
    # insert near notes/source/meta if possible
    if re.search(r"\bnotes\s*:", obj_text):
      obj_text = re.sub(r"(\bnotes\s*:\s*[^,\n]+,?)",
                        r"\1\n        action_tier: __action_tier,\n        tier_disclosure_title: __tier_disclosure_title ?? null,\n        tier_disclosure_body: __tier_disclosure_body ?? null,",
                        obj_text, count=1)
      return obj_text
    if re.search(r"\bsource\s*:", obj_text):
      obj_text = re.sub(r"(\bsource\s*:\s*[^,\n]+,?)",
                        r"\1\n        action_tier: __action_tier,\n        tier_disclosure_title: __tier_disclosure_title ?? null,\n        tier_disclosure_body: __tier_disclosure_body ?? null,",
                        obj_text, count=1)
      return obj_text
    # else put at top after first line
    lines = obj_text.splitlines(True)
    if len(lines) >= 2:
      lines.insert(1, "        action_tier: __action_tier,\n        tier_disclosure_title: __tier_disclosure_title ?? null,\n        tier_disclosure_body: __tier_disclosure_body ?? null,\n")
      return "".join(lines)
    return obj_text

  changed = False
  pat = re.compile(r"(await\s+dbDelegateTask\s*\(\s*db\s*,\s*\{)([\s\S]*?)(\}\s*\)\s*;)", re.M)
  m = pat.search(s)
  if m:
    before, obj, after = m.group(1), m.group(2), m.group(3)
    obj2 = inject_into_obj(obj)
    if obj2 != obj:
      s = s[:m.start()] + before + obj2 + after + s[m.end():]
      changed = True

  # 3) make missing disclosure return 400 where possible (best-effort)
  if "TIER_DISCLOSURE_REQUIRED" in s:
    s = re.sub(
      r"(catch\s*\(\s*err\s*\)\s*\{\s*)([\s\S]*?)(return\s+res\.status\()\s*500(\)\.json)",
      r"\1\2\3((err && err.code==='TIER_DISCLOSURE_REQUIRED') ? 400 : 500)\4",
      s,
      count=1
    )

  p.write_text(s)
  return True

paths = [Path(x) for x in sys.argv[1:] if x and Path(x).exists()]
if not paths:
  raise SystemExit("ERROR: no existing files provided to patch")

for p in paths:
  patch_file(p)
  print(f"OK: patched {p}")
