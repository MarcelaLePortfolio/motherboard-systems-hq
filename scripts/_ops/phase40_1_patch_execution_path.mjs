import fs from "node:fs";
import path from "node:path";
import child_process from "node:child_process";

function sh(cmd) {
  return child_process.execSync(cmd, { stdio: ["ignore", "pipe", "pipe"] }).toString("utf8");
}

function listFiles() {
  const out = sh("git ls-files");
  return out
    .split("\n")
    .map((s) => s.trim())
    .filter(Boolean)
    .filter((f) => /\.(mjs|js|ts|tsx)$/.test(f))
    .filter((f) => !f.startsWith("node_modules/"));
}

function read(file) {
  return fs.readFileSync(file, "utf8");
}

function write(file, content) {
  fs.writeFileSync(file, content, "utf8");
}

function alreadyPatched(content) {
  return /policyEvalShadow|policyShadowEnabled|policyAuditWrite/.test(content);
}

function scoreFile(f, c) {
  const patterns = [
    /server\/.*(worker|executor|execute|runner|dispatch|claim|lease|heartbeat|reclaim).*?\.(mjs|js|ts)$/i,
    /server\/.*(agent|skill|tools?|orchestr|router).*?\.(mjs|js|ts)$/i,
    /server\/.*task.*?\.(mjs|js|ts)$/i,
    /workers?\/.*?\.(mjs|js|ts)$/i,
  ];

  let score = 0;
  for (let i = 0; i < patterns.length; i++) {
    if (patterns[i].test(f)) score += (patterns.length - i) * 10;
  }

  if (/runSkill\s*\(|run_skill\s*\(|invokeSkill\s*\(|invoke_skill\s*\(/.test(c)) score += 60;
  if (/executeTask|performTask|runTask|dispatchTask|handleTask|processTask|execute\s*\(/i.test(c)) score += 40;
  if (/claim(_one)?|lease|heartbeat|reclaim/i.test(c)) score += 20;
  if (/task_events|run_view|tasks\b/i.test(c)) score += 10;

  return score;
}

function candidateTargets(files) {
  const explicit = process.env.PHASE40_TARGET_FILE;
  if (explicit) return [explicit];

  const scored = [];
  for (const f of files) {
    const c = read(f);
    if (alreadyPatched(c)) continue;

    const s = scoreFile(f, c);
    if (s > 0) scored.push([s, f]);
  }
  scored.sort((a, b) => b[0] - a[0]);
  return scored.map((x) => x[1]);
}

function computeRelPolicyDir(targetFile) {
  const fromDir = path.posix.dirname(targetFile);
  const policyDir = "server/policy";
  let rel = path.posix.relative(fromDir, policyDir);
  if (!rel.startsWith(".")) rel = "./" + rel;
  return rel;
}

function ensureImports(content, relPolicyDir) {
  const importBlock =
    `import { policyShadowEnabled } from "${relPolicyDir}/policy_flags.mjs";\n` +
    `import { policyEvalShadow } from "${relPolicyDir}/policy_eval.mjs";\n` +
    `import { policyAuditWrite } from "${relPolicyDir}/policy_audit.mjs";\n`;

  if (/^\s*import\s+\{?\s*policyShadowEnabled\b/m.test(content)) return content;

  const m = content.match(/^(?:\s*import[^\n]*\n)+/m);
  if (m) return content.slice(0, m[0].length) + importBlock + content.slice(m[0].length);

  return importBlock + "\n" + content;
}

function injectShadowEval(content) {
  if (alreadyPatched(content)) throw new Error("already_patched");

  const snippet = [
    `  if (policyShadowEnabled(process.env)) {`,
    `    const __task = (typeof task !== "undefined" ? task : (typeof payload !== "undefined" ? payload?.task : undefined)) ?? null;`,
    `    const __run  = (typeof run  !== "undefined" ? run  : (typeof payload !== "undefined" ? payload?.run  : undefined)) ?? null;`,
    `    const __policyAudit = await policyEvalShadow({ task: __task, run: __run }, process.env);`,
    `    await policyAuditWrite(__policyAudit);`,
    `  }`,
    ``,
  ].join("\n");

  const anchors = [
    // exported named functions
    /(\n|^)\s*export\s+async\s+function\s+([A-Za-z0-9_$]+)\s*\([^)]*\)\s*\{\s*\n/,
    // named functions
    /(\n|^)\s*async\s+function\s+([A-Za-z0-9_$]+)\s*\([^)]*\)\s*\{\s*\n/,
    // export const foo = async (...) => {
    /(\n|^)\s*export\s+const\s+([A-Za-z0-9_$]+)\s*=\s*async\s*\([^)]*\)\s*=>\s*\{\s*\n/,
    // const foo = async (...) => {
    /(\n|^)\s*const\s+([A-Za-z0-9_$]+)\s*=\s*async\s*\([^)]*\)\s*=>\s*\{\s*\n/,
    // let foo = async (...) => {
    /(\n|^)\s*let\s+([A-Za-z0-9_$]+)\s*=\s*async\s*\([^)]*\)\s*=>\s*\{\s*\n/,
    // class method: async foo(...) {
    /(\n|^)\s*async\s+([A-Za-z0-9_$]+)\s*\([^)]*\)\s*\{\s*\n/,
  ];

  // Prefer likely execution-ish names if present
  const prefer = /(execute|dispatch|run|perform|handle|process|claim|work|tick|loop|step)/i;

  for (const re of anchors) {
    let m;
    const r = new RegExp(re.source, re.flags.includes("m") ? re.flags : re.flags + "m");
    while ((m = r.exec(content)) !== null) {
      const name = m[2] || m[1] || "";
      if (name && !prefer.test(name)) continue;
      const idx = (m.index ?? 0) + m[0].length;
      return content.slice(0, idx) + snippet + content.slice(idx);
    }
  }

  // If no preferred anchor matched, inject into first anchor match
  for (const re of anchors) {
    const m = content.match(re);
    if (!m) continue;
    const idx = (m.index ?? 0) + m[0].length;
    return content.slice(0, idx) + snippet + content.slice(idx);
  }

  // Fallback: inject above first runSkill/run_skill/invokeSkill line
  const rs = content.search(/\b(runSkill|run_skill|invokeSkill|invoke_skill)\s*\(/);
  if (rs >= 0) {
    const lineStart = content.lastIndexOf("\n", rs) + 1;
    return content.slice(0, lineStart) + snippet + content.slice(lineStart);
  }

  throw new Error("no_viable_injection_point");
}

function tryPatchFile(target) {
  const relPolicyDir = computeRelPolicyDir(target);
  const before = read(target);
  if (alreadyPatched(before)) return { ok: false, reason: "already_patched", target };

  let after = before;
  after = ensureImports(after, relPolicyDir);
  after = injectShadowEval(after);

  if (after === before) return { ok: false, reason: "no_changes", target };

  write(target, after);
  return { ok: true, target };
}

function main() {
  const files = listFiles();
  const targets = candidateTargets(files);

  if (!targets.length) throw new Error("no_targets_found");

  const attempts = [];
  for (const t of targets.slice(0, 60)) {
    try {
      const r = tryPatchFile(t);
      if (r.ok) {
        // eslint-disable-next-line no-console
        console.log(`patched_execution_path=${r.target}`);
        return;
      }
      attempts.push({ target: t, reason: r.reason });
    } catch (e) {
      attempts.push({ target: t, reason: String(e?.message || e) });
      continue;
    }
  }

  // eslint-disable-next-line no-console
  console.error(JSON.stringify({ error: "patch_failed", attempts: attempts.slice(0, 20) }, null, 2));
  process.exit(2);
}

main();
