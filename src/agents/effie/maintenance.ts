import fs from "node:fs";
import path from "node:path";

const ROOT = process.cwd();
const QUEUE_DIR = path.join(ROOT, "memory", "queue");

function log(msg: string) {
  // eslint-disable-next-line no-console
  console.log(`[EffieMaint] ${msg}`);
}

export async function runMaintenanceOnce() {
  try {
    fs.mkdirSync(QUEUE_DIR, { recursive: true });

    // 1) Queue health
    const entries = fs.readdirSync(QUEUE_DIR).filter(f => f.endsWith(".json"));
    log(`queue items: ${entries.length}`);

    // 2) Cleanup: stale tmp files (older than 10 minutes)
    const now = Date.now();
    const tmpFiles = fs.readdirSync(QUEUE_DIR).filter(f => f.endsWith(".tmp"));
    let removed = 0;
    for (const f of tmpFiles) {
      const full = path.join(QUEUE_DIR, f);
      try {
        const ageMs = now - fs.statSync(full).mtimeMs;
        if (ageMs > 10 * 60 * 1000) { fs.rmSync(full, { force: true }); removed++; }
      } catch { /* ignore */ }
    }
    log(`stale tmp removed: ${removed}`);

    // 3) Placeholder hooks for later
    // - verifyLocks()
    // - rotateLogs()
    // - compactLedger()
    // Just stubs for now.
    log("stubs ok");
  } catch (e: any) {
    log(`error: ${e?.message || String(e)}`);
  }
}
