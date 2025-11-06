// <0001fadc> Phase 9 — Atlas creation fallback + cinematic 1 Hz reflections
import fs from "fs";
import path from "path";

const root = process.cwd();
const tmpDir = path.join(root, "public", "tmp");
const atlasStatusPath = path.join(tmpDir, "atlas-status.json");
const reflectionsPath = path.join(tmpDir, "reflections.json");

fs.mkdirSync(tmpDir, { recursive: true });

type AtlasStep = {
  t: number;
  step: string;
  detail?: string;
};

const sequence = [
  "Bootstrapping Atlas workspace",
  "Validating schema",
  "Spinning Cade build task",
  "Effie preparing local ops",
  "Provisioning runtime",
  "Finalizing config",
  "Atlas Online"
];

function writeStatus(stepIndex: number) {
  const now = Math.floor(Date.now() / 1000);
  const steps: AtlasStep[] = sequence.slice(0, stepIndex + 1).map((s, idx) => ({
    t: now - (stepIndex - idx),
    step: s,
    detail: idx === stepIndex ? "active" : "ok",
  }));
  const status = {
    status: stepIndex + 1 < sequence.length ? "creating" : "online",
    sequence: steps,
    updated_at: now,
  };
  fs.writeFileSync(atlasStatusPath, JSON.stringify(status, null, 2), "utf8");
}

function appendReflection(line: string) {
  let rows: any[] = [];
  try { rows = JSON.parse(fs.readFileSync(reflectionsPath, "utf8")); } catch {}
  const now = new Date().toISOString();
  rows.unshift({ id: `atlas-${Date.now()}`, content: line, created_at: now });
  rows = rows.slice(0, 25);
  fs.writeFileSync(reflectionsPath, JSON.stringify(rows, null, 2), "utf8");
}

(async () => {
  console.log("🎬 Starting Atlas creation sequence @ 1 Hz…");
  for (let i = 0; i < sequence.length; i++) {
    writeStatus(i);
    const s = sequence[i];
    appendReflection(`🎞️ [Atlas] ${s}…`);
    await new Promise((r) => setTimeout(r, 1000));
  }
  appendReflection("✅ [Atlas] Atlas Online — ready for demo.");
  console.log("✅ Atlas creation sequence complete.");
})();
