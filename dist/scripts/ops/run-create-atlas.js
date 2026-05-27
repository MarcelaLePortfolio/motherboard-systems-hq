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
        reflectionsPath: "public/tmp/reflections.json",
        statusPath: "public/tmp/atlas-status.json"
    });
    console.log("✅ Atlas creation complete.");
})();
