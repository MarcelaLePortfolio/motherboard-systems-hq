import fs from "node:fs";
import path from "node:path";

function walk(dir, out = []) {
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const name = ent.name;
    if (name === "node_modules" || name === "dist" || name === "build" || name === ".next") continue;
    const p = path.join(dir, name);
    if (ent.isDirectory()) walk(p, out);
    else out.push(p);
  }
  return out;
}

function scoreFile(txt) {
  let s = 0;
  if (/POLICY_(ENFORCE|SHADOW|MODE)/.test(txt)) s += 6;
  if (/action_tier/i.test(txt)) s += 6;
  if (/policy/i.test(txt)) s += 2;
  if (/evaluat/i.test(txt)) s += 3;
  if (/audit/i.test(txt)) s += 3;
  if (/decision/i.test(txt)) s += 2;
  if (/structural/i.test(txt)) s += 1;
  return s;
}

function pickCandidate(files) {
  const ranked = files
    .filter(f => /\.(ts|tsx|js)$/.test(f))
    .map(f => {
      const txt = fs.readFileSync(f, "utf8");
      return { f, txt, score: scoreFile(txt) };
    })
    .filter(x => x.score >= 10)
    .sort((a,b) => b.score - a.score);

  return ranked[0] ?? null;
}

function hasMarker(txt) {
  return txt.includes("PHASE45_POLICY_GRANTS_INTEGRATED");
}

function insertImport(lines, importStmt) {
  let lastImport = -1;
  for (let i = 0; i < Math.min(lines.length, 200); i++) {
    if (/^\s*import\s/.test(lines[i])) lastImport = i;
  }
  if (lastImport === -1) return { ok: false, why: "no import block found" };

  // avoid dupes
  if (lines.some(l => l.includes("resolvePolicyGrant") || l.includes(importStmt.trim()))) {
    return { ok: true, lines };
  }

  lines.splice(lastImport + 1, 0, importStmt);
  return { ok: true, lines };
}

function patchEvaluator(txt) {
  if (hasMarker(txt)) return { ok: true, out: txt, changed: false };

  const lines = txt.split("\n");

  // 1) add import
  const importStmt = `import { resolvePolicyGrant } from "./policy_grants"; // PHASE45_POLICY_GRANTS_INTEGRATED`;
  const imp = insertImport(lines, importStmt);
  if (!imp.ok) return { ok: false, why: imp.why };

  // 2) find a late "return" to hook before
  let hookIdx = -1;
  for (let i = lines.length - 1; i >= 0; i--) {
    const l = lines[i];
    if (/\breturn\b/.test(l) && !/return\s*;/.test(l)) {
      hookIdx = i;
      break;
    }
  }
  if (hookIdx === -1) return { ok: false, why: "no return statement found to hook" };

  // 3) inject best-effort override logic
  const inject = [
    "",
    "  // PHASE45_POLICY_GRANTS_INTEGRATED: deterministic override authority (auditable policy_grants)",
    "  // Contract: subject + scope must be stable strings in your evaluator context.",
    "  // This block is best-effort and will not throw (grant lookup failures do not break evaluation).",
    "  try {",
    "    // Attempt to discover subject/scope from common names used in this codebase.",
    "    // If your evaluator uses different variable names, adjust here.",
    "    // @ts-ignore",
    "    const __subject = (typeof subject === 'string' ? subject : (typeof principal === 'string' ? principal : (typeof actor === 'string' ? actor : '')));",
    "    // @ts-ignore",
    "    const __scope = (typeof scope === 'string' ? scope : (typeof policy_scope === 'string' ? policy_scope : (typeof policyScope === 'string' ? policyScope : '')));",
    "",
    "    // Attempt to reference a result object if present (common patterns: result, decision, audit).",
    "    // @ts-ignore",
    "    const __res: any = (typeof result !== 'undefined' ? result : (typeof evalResult !== 'undefined' ? evalResult : undefined));",
    "",
    "    // Normalize decision into allow/deny-ish signals (supports booleans and strings).",
    "    // @ts-ignore",
    "    const __rawDecision: any = (typeof decision !== 'undefined' ? decision : (__res?.decision));",
    "    const __isAllow = (__rawDecision === true || __rawDecision === 'allow');",
    "    const __isDeny = (__rawDecision === false || __rawDecision === 'deny' || __rawDecision === 'block');",
    "",
    "    if (__subject && __scope) {",
    "      // Optional: deny-grant can override allow",
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
    "      // Allow-grant can override deny/block",
    "      // re-read decision after deny-grant attempt",
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

const serverRoot = "server";
if (!fs.existsSync(serverRoot) || !fs.statSync(serverRoot).isDirectory()) {
  console.error("ERROR: expected ./server directory");
  process.exit(2);
}

const files = walk(serverRoot);
const cand = pickCandidate(files);

if (!cand) {
  console.error("ERROR: could not find a likely evaluator file under server/ to patch");
  process.exit(3);
}

const patched = patchEvaluator(cand.txt);
if (!patched.ok) {
  console.error("ERROR: autopatch refused for:", cand.f);
  console.error("WHY:", patched.why);
  process.exit(4);
}

if (!patched.changed) {
  console.log("OK: already integrated (marker present):", cand.f);
  process.exit(0);
}

fs.writeFileSync(cand.f, patched.out, "utf8");
console.log("OK: patched:", cand.f);
