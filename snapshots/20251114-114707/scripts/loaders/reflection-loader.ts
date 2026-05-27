// <0001fac9> Phase 4.5 — Static Reflections Export (Correct Column: content)
import fs from "fs";
import path from "path";
import Database from "better-sqlite3";

const dbPath = path.join(process.cwd(), "db", "main.db");
const outputPath = path.join(process.cwd(), "public", "tmp", "reflections.json");

try {
  const db = new Database(dbPath);
  console.log(`🧩 Using SQLite database at: ${dbPath}`);

  const rows = db
    .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 10")
    .all();

  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, JSON.stringify(rows, null, 2), "utf8");

  console.log(`✅ Reflections exported → ${outputPath}`);
  db.close();
} catch (err) {
  console.error("❌ Reflection loader failed:", err);
}
