// <0001fafd> Phase 9.3 — Automated Demo Playback Orchestrator
// Simulates cinematic agent delegation, reflection flow, and synchronized dashboard updates

import { execSync } from "child_process";
import fs from "node:fs";
import path from "path";
import { sqlite } from "../../db/client";

const reflectionsPath = path.join(process.cwd(), "public", "tmp", "reflections.json");

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function runDemoPlayback() {
  console.log("🎬 Starting Automated Demo Playback Sequence...");
  try {
    console.log("�� Resetting environment to demo baseline...");
    execSync("bash scripts/demo/restore-demo-baseline.sh", { stdio: "inherit" });

    console.log("💾 Creating fallback Atlas task...");
    execSync("npx tsx scripts/demo/run-create-atlas.ts", { stdio: "inherit" });

    console.log("🌱 Loading reflections from snapshot...");
    const reflections = JSON.parse(fs.readFileSync(reflectionsPath, "utf8"));

    console.log("🪞 Playing reflections at cinematic 1 Hz...");
    for (const reflection of reflections.reverse()) {
      sqlite
        .prepare("INSERT INTO reflection_index (content, created_at) VALUES (?, datetime('now'))")
        .run(reflection.content);
      console.log(`✨ ${reflection.content}`);
      await delay(1000); // 1 Hz pacing
    }

    console.log("🚀 Triggering agent prewarm and live status check...");
    execSync("bash scripts/demo/prewarm-agents.sh", { stdio: "inherit" });

    console.log("🎉 Demo playback complete — dashboard should now display synchronized cinematic flow.");
  } catch (err) {
    console.error("❌ Demo playback encountered an error:", err);
  }
}

runDemoPlayback();
