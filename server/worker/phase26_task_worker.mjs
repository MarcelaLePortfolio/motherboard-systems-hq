import fs from "fs";
import path from "path";

const POSTGRES_URL = process.env.POSTGRES_URL;
if (!POSTGRES_URL) throw new Error("POSTGRES_URL required");

const WORKER_DIR = path.resolve("/app/server/worker");

function resolveSqlContracts() {
  let files = [];
  try {
    files = fs.readdirSync(WORKER_DIR);
  } catch (e) {
    throw new Error(`Worker directory not found: ${WORKER_DIR}`);
  }

  const phase32 = files.filter(f => f.startsWith("phase32_") && f.endsWith(".sql"));
  const phase27 = files.filter(f => f.startsWith("phase27_") && f.endsWith(".sql"));

  if (phase32.length > 0) {
    return {
      phase: "32",
      root: WORKER_DIR,
      files: phase32
    };
  }

  if (phase27.length > 0) {
    return {
      phase: "27",
      root: WORKER_DIR,
      files: phase27
    };
  }

  throw new Error("No SQL contracts found (expected phase32_* or phase27_* in /app/server/worker)");
}

const SQL = resolveSqlContracts();

console.log("[worker] resolved sql contracts:", {
  phase: SQL.phase,
  count: SQL.files.length
});

for (const f of SQL.files) {
  console.log("[worker] contract:", f);
}

async function main() {
  console.log("[worker] started with POSTGRES_URL:", POSTGRES_URL);
  console.log("[worker] running in phase:", SQL.phase);

  setInterval(() => {
    console.log("[worker] heartbeat");
  }, 30000);
}

main().catch(err => {
  console.error("[worker] fatal error:", err);
  process.exit(1);
});
