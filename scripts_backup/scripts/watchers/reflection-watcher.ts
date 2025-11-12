// <0001fad4> Phase 4.6 — Reflection Watcher Expanded (WAL/SHM-aware auto-export)
import fs from "fs";
import path from "path";
import Database from "better-sqlite3";
import chokidar from "chokidar";

const dbDir = path.join(process.cwd(), "db");
const dbPath = path.join(dbDir, "main.db");
const walPath = dbPath + "-wal";
const shmPath = dbPath + "-shm";
const outputPath = path.join(process.cwd(), "public", "tmp", "reflections.json");

function exportReflections() {
  try {
    const db = new Database(dbPath);
    const rows = db
      .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 10")
      .all();
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, JSON.stringify(rows, null, 2), "utf8");
    db.close();
    console.log(`<0001f7e0> Reflections auto-exported → ${outputPath}`);
  } catch (err) {
    console.error("❌ Reflection watcher export failed:", err);
  }
}

console.log(`👁️  Watching for reflection_index updates (WAL/SHM-aware) in ${dbDir}...`);
exportReflections();

const watcher = chokidar.watch([dbPath, walPath, shmPath], {
  persistent: true,
  ignoreInitial: true,
});
watcher.on("change", (file) => {
  console.log(`🔁 Detected change in ${path.basename(file)} — regenerating reflections.json...`);
  exportReflections();
});
