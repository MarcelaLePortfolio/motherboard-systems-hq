import fs from "node:fs";
import path from "node:path";
import { normalizePolicyAudit } from "./policy_audit_shape.mjs";

/**
 * Phase 40.4 — Optional audit rotation (size-based).
 * - Always stdout JSON line.
 * - Optional local capture when POLICY_AUDIT_PATH is set (append-only JSONL).
 * - Optional rotation when POLICY_AUDIT_MAX_BYTES > 0.
 * - Must not throw.
 */

function toInt(v, dflt) {
  const n = Number.parseInt(String(v ?? ""), 10);
  return Number.isFinite(n) ? n : dflt;
}

function safeMkdirpForFile(filePath) {
  try {
    const dir = path.dirname(filePath);
    if (dir && dir !== "." && dir !== "/") fs.mkdirSync(dir, { recursive: true });
  } catch (_) {
    // swallow
  }
}

function rotateIfNeeded(filePath, maxBytes, maxFiles) {
  if (!filePath || maxBytes <= 0) return;
  if (maxFiles < 1) maxFiles = 1;

  try {
    const st = fs.statSync(filePath);
    if (!st.isFile()) return;
    if (st.size < maxBytes) return;
  } catch (_) {
    // missing file or stat error -> no rotation
    return;
  }

  try {
    // shift: file.(maxFiles-1) -> file.maxFiles, ... file.1 -> file.2
    for (let i = maxFiles - 1; i >= 1; i -= 1) {
      const from = `${filePath}.${i}`;
      const to = `${filePath}.${i + 1}`;
      try {
        fs.renameSync(from, to);
      } catch (_) {
        // ignore missing
      }
    }

    // file -> file.1
    try {
      fs.renameSync(filePath, `${filePath}.1`);
    } catch (_) {
      // swallow
    }

    // best-effort: prune oldest (file.(maxFiles+1)) if it exists due to external factors
    try {
      fs.rmSync(`${filePath}.${maxFiles + 1}`, { force: true });
    } catch (_) {
      // swallow
    }
  } catch (_) {
    // swallow
  }
}

export async function policyAuditWrite(audit = {}, env = process.env) {
  try {
    const normalized = normalizePolicyAudit(audit, env);
    const line = JSON.stringify({
      t: normalized.meta.emitted_at_iso,
      channel: "policy_audit",
      audit: normalized,
    });

    // eslint-disable-next-line no-console
    console.log(line);

    const filePath = env?.POLICY_AUDIT_PATH ? String(env.POLICY_AUDIT_PATH) : "";
    if (filePath) {
      try {
        safeMkdirpForFile(filePath);

        const maxBytes = toInt(env?.POLICY_AUDIT_MAX_BYTES, 0);
        const maxFiles = toInt(env?.POLICY_AUDIT_MAX_FILES, 5);

        rotateIfNeeded(filePath, maxBytes, maxFiles);

        fs.appendFileSync(filePath, line + "\n", { encoding: "utf8" });
      } catch (_) {
        // swallow
      }
    }
  } catch (_) {
    // swallow
  }
}
