import fs from "node:fs";
import path from "node:path";

const REPO_ROOT = process.cwd();

function walk(dir, out = []) {
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const name = ent.name;
    if (
      name === "node_modules" ||
      name === ".git" ||
      name === "dist" ||
      name === "build" ||
      name === ".next" ||
      name === ".turbo" ||
      name === "coverage"
    ) continue;

    const p = path.join(dir, name);
    if (ent.isDirectory()) walk(p, out);
    else out.push(p);
  }
  return out;
}

function scoreFile(txt) {
  let s = 0;

  // Strong policy/eval signals
  if (/policy/i.test(txt)) s += 2;
  if (/evaluat|evaluator/i.test(txt)) s += 2;
  if (/decision/i.test(txt)) s += 1;
  if (/audit/i.test(txt)) s += 2;

  // Known project motifs
  if (/action_tier/i.test(txt)) s += 6;
  if (/POLICY_(ENFORCE|SHADOW|MODE)/.test(txt)) s += 6;
  if (/ruleset/i.test(txt)) s += 2;
  if (/governance/i.test(txt)) s += 2;
  if (/structural/i.test(txt)) s += 1;

  // Hints that it’s the place we want
  if (/task_events/i.test(txt)) s += 1;
  if (/override|grant/i.test(txt)) s += 1;

  return s;
}

function pickCandidates(files) {
  const ranked = files
    .filter(f => /\.(ts|tsx|js)$/.test(f))
    .filter(f => !/\/scripts\//.test(f.replace(/\\/g,"/")))
    .map(f => {
      const txt = fs.readFileSync(f, "utf8");
      return { f, txt, score: scoreFile(txt) };
    })
    .filter(x => x.score >= 3)
    .sort((a,b) => b.score - a.score);

  return ranked.slice(0, 25);
}

function hasMarker(txt) {
  return txt.includes("PHASE45_POLICY_GRANTS_INTEGRATED");
}

function insertImport(lines, importStmt) {
  let lastImport = -1;
  for (let i = 0; i < Math.min(lines.length, 300); i++) {
    if (/^\s*import\s/.test(lines[i])) lastImport = i;
  }
  if (lastImport === -1) return { ok: false, why: "no import block found" };

  if (lines.some(l => l.includes("resolvePolicyGrant") || l.includes(importStmt.trim()))) {
    return { ok: true, lines };
  }

  lines.splice(lastImport + 1, 0, importStmt);
  return { ok: true, lines };
}

function relImport(fromFile, targetFile) {
  const fromDir = path.dirname(fromFile);
  let rel = path.relative(fromDir, targetFile).replace(/\\/g, "/");
  if (!rel.startsWith(".")) rel = "./" + rel;
  rel = rel.replace(/\.ts$/,"");
  return rel;
}

function patchEvaluator(txt, relPathToGrants) {
  if (hasMarker(txt)) return { ok: true, out: txt, changed: false };

  const lines = txt.split("\n");

  const importStmt = `import { resolvePolicyGrant } from "${relPathToGrants}"; // PHASE45_POLICY_GRANTS_INTEGRATED`;
  const imp = insertImport(lines, importStmt);
  if (!imp.ok) return { ok: false, why: imp.why };

  // Hook as late as possible before a return
  let hookIdx = -1;
  for (let i = lines.length - 1; i >= 0; i--) {
    if (/\breturn\b/.test(lines[i]) && !/return\s*;/.test(lines[i])) {
      hookIdx = i;
      break;
    }
  }
  if (hookIdx === -1) return { ok: false, why: "no return statement found to hook" };

  const inject = [
    "",
    "  // PHASE45_POLICY_GRANTS_INTEGRATED: deterministic override authority (auditable policy_grants)",
    "  // Best-effort: never throws; enriches audit with policy_grant evidence when applied.",
    "  try {",
    "    // @ts-ignore",
    "    const __subject = (typeof subject === 'string' ? subject : (typeof principal === 'string' ? principal : (typeof actor === 'string' ? actor : '')));",
    "    // @ts-ignore",
    "    const __scope = (typeof scope === 'string' ? scope : (typeof policy_scope === 'string' ? policy_scope : (typeof policyScope === 'string' ? policyScope : '')));",
    "    // @ts-ignore",
    "    const __res: any = (typeof result !== 'undefined' ? result : (typeof evalResult !== 'undefined' ? evalResult : undefined));",
    "    // @ts-ignore",
    "    const __rawDecision: any = (typeof decision !== 'undefined' ? decision : (__res?.decision));",
    "    const __isAllow = (__rawDecision === true || __rawDecision === 'allow');",
    "    const __isDeny = (__rawDecision === false || __rawDecision === 'deny' || __rawDecision === 'block');",
    "",
    "    if (__subject && __scope) {",
    "      if (__isAllow) {",
    "        const gD = await resolvePolicyGrant({ subject: __subject, scope: __scope, want: 'deny' });",
    "        if (gD.hit) {",
    "          if (typeof decision !== 'undefined') {",
    "            // @ts-ignore",
    "            decision = (__rawDecision === true ? false : 'deny');",
    "          }",
    "          if (__res && typeof __res === 'object') {",
    "            __res.decision = (__rawDecision === true ? false : 'deny');",
    "          }",
    "          // @ts-ignore",
    "          const __audit: any = (typeof audit !== 'undefined' ? audit : (__res?.audit));",
    "          const __audit2 = { ...( __audit ?? {} ), policy_grant: { kind: 'deny', ...gD.grant } };",
    "          if (typeof audit !== 'undefined') {",
    "            // @ts-ignore",
    "            audit = __audit2;",
    "          }",
    "          if (__res && typeof __res === 'object') {",
    "            __res.audit = __audit2;",
    "          }",
    "        }",
    "      }",
    "",
    "      // re-read after possible deny grant",
    "      // @ts-ignore",
    "      const __rawDecision2: any = (typeof decision !== 'undefined' ? decision : (__res?.decision));",
    "      const __isDeny2 = (__rawDecision2 === false || __rawDecision2 === 'deny' || __rawDecision2 === 'block');",
    "      if (__isDeny2) {",
    "        const gA = await resolvePolicyGrant({ subject: __subject, scope: __scope, want: 'allow' });",
    "        if (gA.hit) {",
    "          if (typeof decision !== 'undefined') {",
    "            // @ts-ignore",
    "            decision = (__rawDecision2 === false ? true : 'allow');",
    "          }",
    "          if (__res && typeof __res === 'object') {",
    "            __res.decision = (__rawDecision2 === false ? true : 'allow');",
    "          }",
    "          // @ts-ignore",
    "          const __audit: any = (typeof audit !== 'undefined' ? audit : (__res?.audit));",
    "          const __audit2 = { ...( __audit ?? {} ), policy_grant: { kind: 'allow', ...gA.grant } };",
    "          if (typeof audit !== 'undefined') {",
    "            // @ts-ignore",
    "            audit = __audit2;",
    "          }",
    "          if (__res && typeof __res === 'object') {",
    "            __res.audit = __audit2;",
    "          }",
    "        }",
    "      }",
    "    }",
    "  } catch (_e) {",
    "    // noop",
    "  }",
    ""
  ];

  lines.splice(hookIdx, 0, ...inject);
  return { ok: true, out: lines.join("\n"), changed: true };
}

const grantsFile = path.join(REPO_ROOT, "server/policy/policy_grants.ts");
if (!fs.existsSync(grantsFile)) {
  console.error("ERROR: missing server/policy/policy_grants.ts");
  process.exit(2);
}

const allFiles = walk(REPO_ROOT);
const cands = pickCandidates(allFiles);

if (!cands.length) {
  console.error("ERROR: no likely evaluator candidates found.");
  console.error("Hint: run `rg -n \"action_tier|POLICY_ENFORCE|POLICY_SHADOW|ruleset|governance\" -S .` to find the evaluator.");
  process.exit(3);
}

console.log("Top candidates:");
for (const c of cands.slice(0, 12)) console.log(`- ${c.score}\t${path.relative(REPO_ROOT, c.f)}`);

const target = cands[0];
const rel = relImport(target.f, grantsFile);
const patched = patchEvaluator(target.txt, rel);

if (!patched.ok) {
  console.error("ERROR: autopatch refused for:", path.relative(REPO_ROOT, target.f));
  console.error("WHY:", patched.why);
  process.exit(4);
}

if (!patched.changed) {
  console.log("OK: already integrated (marker present):", path.relative(REPO_ROOT, target.f));
  process.exit(0);
}

fs.writeFileSync(target.f, patched.out, "utf8");
console.log("OK: patched:", path.relative(REPO_ROOT, target.f));
