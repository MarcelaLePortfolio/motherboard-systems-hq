// scripts/ops/run-create-atlas.ts
import { createEntity } from "./create-entity";

const mode = process.argv.includes("--live") ? "live" : "demo";

(async () => {
  console.log(`🎬 Starting Atlas creation (${mode}) @ 1 Hz…`);
  await createEntity({
    name: "Atlas",
    kind: "workspace",
    mode,
    paceMs: 1000,
    targetDir: "projects/Atlas",
    reflectionsPath: "public/tmp/reflectionson",
    statusPath: "public/tmp/atlas-statuson"
  });
  console.log("✅ Atlas creation complete.");
})();
