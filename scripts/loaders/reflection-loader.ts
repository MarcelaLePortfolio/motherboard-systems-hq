// <0001fac1> Phase 4.4.3 — Reflection Loader (safe, decoupled)
import fs from "fs";
import path from "path";
import db from "../../db/client";

const outputPath = path.join(process.cwd(), "public", "tmp", "reflections.json");

try {
  const rows = db
    .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 10")
    .all();
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, JSON.stringify(rows, null, 2), "utf8");
  console.log(`✅ Reflections exported → ${outputPath}`);
} catch (err) {
  console.error("❌ Reflection loader failed:", err);
  process.exit(1);
}
