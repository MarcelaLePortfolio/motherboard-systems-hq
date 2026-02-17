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

function pickTarget(files) {
  const patterns = [
    /server\/.*(worker|executor|execute|runner).*?\.(mjs|js|ts)$/i,
    /server\/.*task.*?\.(mjs|js|ts)$/i,
    /workers?\/.*?\.(mjs|js|ts)$/i,
  ];

  const scored = [];

  for (const f of files) {
    let score = 0;
    for (let i = 0; i < patterns.length; i++) {
      if (patterns[i].test(f)) score += (patterns.length - i) * 10;
    }
    if (score === 0) continue;

    const c = read(f);

    // Look for execution-ish signals
    if (/runSkill\s*\(/.test(c)) score += 30;
    if (/executeTask|performTask|runTask|dispatchTask|invokeSkill|toolCall/i.test(c)) score += 30;
    if (/status\s*=\s*['"]running['"]/.test(c)) score += 10;
    if (/task_events|run_view|tasks\b/.test(c)) score += 10;

    // Avoid already patched
    if (/policyEvalShadow|policyShadowEnabled|policyAuditWrite/.test(c)) score = 0;

    if (score > 0) scored.push([score, f]);
  }

  scored.sort((a, b) => b[0] - a[0]);
  return scored.length ? scored[0][1] : null;
}

function ensureImports(content, relPolicyDir) {
  const importFlags = `import { policyShadowEnabled } from "${relPolicyDir}/policy_flags.mjs";\n`;
  const importEval = `import { policyEvalShadow } from "${relPolicyDir}/policy_eval.mjs";\n`;
  const importAudit = `import { policyAuditWrite } from "${relPolicyDir}/policy_audit.mjs";\n`;

  let c = content;

  // Insert after the last import line, or at top.
  const importBlock = (importFlags + importEval + importAudit);

  if (!/^\s*import\s+\{?\s*policyShadowEnabled\b/m.test(c)) {
    const m = c.match(/^(?:\s*import[^\n]*\n)+/m);
    if (m) {
      c = c.slice(0, m[0].length) + importBlock + c.slice(m[0].length);
    } else {
      c = importBlock + "\n" + c;
    }
  }

  return c;
}

function injectShadowEval(content) {
  // Heuristic: inject near the first obvious "execute" function body start.
  // We try a few anchors in priority order.
  const anchors = [
    /async function\s+(executeTask|performTask|runTask|dispatchTask)\s*\([^)]*\)\s*\{\n/,
    /export\s+async function\s+(executeTask|performTask|runTask|dispatchTask)\s*\([^)]*\)\s*\{\n/,
    /async\s+(executeTask|performTask|runTask|dispatchTask)\s*\([^)]*\)\s*\{\n/,
    /async function\s*\([^)]*\)\s*\{\n/,
  ];

  const snippet = [
    `  if (policyShadowEnabled(process.env)) {`,
    `    const __policyAudit = await policyEvalShadow({ task, run }, process.env);`,
    `    await policyAuditWrite(__policyAudit);`,
    `  }`,
    ``,
  ].join("\n");

  for (const re of anchors) {
    const m = content.match(re);
    if (!m) continue;

    const idx = m.index + m[0].length;
    return content.slice(0, idx) + snippet + content.slice(idx);
  }

  // Fallback: inject near first "runSkill(" call
  const rs = content.search(/runSkill\s*\(/);
  if (rs >= 0) {
    // inject above the line containing runSkill
    const lineStart = content.lastIndexOf("\n", rs) + 1;
    return content.slice(0, lineStart) + snippet + content.slice(lineStart);
  }

  throw new Error("No viable injection point found (no execute anchor, no runSkill anchor).");
}

function computeRelPolicyDir(targetFile) {
  // targetFile is repo-relative; policy dir is server/policy
  const fromDir = path.posix.dirname(targetFile);
  const policyDir = "server/policy";
  let rel = path.posix.relative(fromDir, policyDir);
  if (!rel.startsWith(".")) rel = "./" + rel;
  return rel;
}

function main() {
  const files = listFiles();
  const target = pickTarget(files);

  if (!target) {
    throw new Error("Could not identify execution-path file to patch.");
  }

  const relPolicyDir = computeRelPolicyDir(target);

  const before = read(target);
  let after = before;

  after = ensureImports(after, relPolicyDir);
  after = injectShadowEval(after);

  if (after === before) {
    throw new Error("Patch produced no changes.");
  }

  write(target, after);

  // Print which file was patched (stdout) for operator visibility.
  // eslint-disable-next-line no-console
  console.log(`patched_execution_path=${target}`);
}

main();
