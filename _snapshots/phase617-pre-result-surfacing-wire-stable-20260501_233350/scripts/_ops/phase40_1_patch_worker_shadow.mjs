import fs from "node:fs";
const TARGET = process.env.PHASE40_TARGET_FILE || "server/worker/phase26_task_worker.mjs";

function read(p) { return fs.readFileSync(p, "utf8"); }
function write(p, s) { fs.writeFileSync(p, s, "utf8"); }

function has(s, re) { return re.test(s); }

function insertAfterImports(src, block) {
  const m = src.match(/^(?:\s*import[^\n]*\n)+/m);
  if (m) return src.slice(0, m[0].length) + block + src.slice(m[0].length);
  return block + "\n" + src;
}

function main() {
  let src = read(TARGET);

  const importBlock =
    `import { policyShadowEnabled } from "../policy/policy_flags.mjs";\n` +
    `import { policyEvalShadow } from "../policy/policy_eval.mjs";\n` +
    `import { policyAuditWrite } from "../policy/policy_audit.mjs";\n`;

  if (!has(src, /\bpolicyShadowEnabled\b/)) {
    src = insertAfterImports(src, importBlock);
  }

  const guardRe = /if\s*\(\s*policyShadowEnabled\s*\(/;
  if (!has(src, guardRe)) {
    const snippet =
`    if (policyShadowEnabled(process.env)) {
      const __task = (typeof task !== "undefined" ? task : (typeof payload !== "undefined" ? payload?.task : undefined)) ?? null;
      const __run  = (typeof run  !== "undefined" ? run  : (typeof payload !== "undefined" ? payload?.run  : undefined)) ?? null;
      const __policyAudit = await policyEvalShadow({ task: __task, run: __run }, process.env);
      await policyAuditWrite(__policyAudit);
    }

`;

    // anchor: insert before first "await" statement in file (best-effort, deterministic)
    const m = src.match(/\n(\s*await\s+[^;\n]+;)/);
    if (m) {
      src = src.replace(/\n(\s*await\s+[^;\n]+;)/, "\n" + snippet + "$1");
    } else {
      // fallback: insert at first opening brace after "async" keyword
      const m2 = src.match(/async[^{]*\{\s*\n/);
      if (!m2) throw new Error("no_injection_point");
      const idx = src.indexOf(m2[0]) + m2[0].length;
      src = src.slice(0, idx) + snippet + src.slice(idx);
    }
  }

  write(TARGET, src);
  // eslint-disable-next-line no-console
  console.log(`patched_worker=${TARGET}`);
}

main();
