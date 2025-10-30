// <0001fad3> Phase 4.6 — Reflection Watcher Automation (auto-export JSON on DB change)
import fs from "fs";
import path from "path";
import Database from "better-sqlite3";
import chokidar from "chokidar";

const dbPath = path.join(process.cwd(), "db", "main.db");
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

console.log(`👁️  Watching for reflection_index updates in ${dbPath}...`);
exportReflections();

const watcher = chokidar.watch(dbPath, { persistent: true, ignoreInitial: true });
watcher.on("change", () => {
  console.log("🔁 Detected reflection_index change — regenerating reflections.json...");
  exportReflections();
});
