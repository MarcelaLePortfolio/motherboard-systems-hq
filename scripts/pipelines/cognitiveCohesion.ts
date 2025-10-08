import fs from "fs";
import path from "path";

const insightsFile = path.resolve("db/insights.jsonl");
const reflectionsFile = path.resolve("db/reflections.jsonl");
const cohesionFile = path.resolve("db/cohesion.jsonl");

function readLines(file: string, limit = 100) {
  if (!fs.existsSync(file)) return [];
  const lines = fs.readFileSync(file, "utf8").trim().split("\n").slice(-limit);
  return lines.map(l => JSON.parse(l));
}

/** Generate cohesive cognitive lesson */
export function generateCognitiveLesson() {
  const insights = readLines(insightsFile, 50);
  const reflections = readLines(reflectionsFile, 50);
  if (!insights.length || !reflections.length)
    throw new Error("Insufficient data: need both insights and reflections.");

  const latestInsight = insights.at(-1)?.insight ?? "";
  const latestReflection = reflections.at(-1)?.feedback ?? "";

  const coherence =
    latestReflection.includes("stable") || latestReflection.includes("no immediate action")
      ? "Stable"
      : latestReflection.includes("error")
      ? "Corrective"
      : "Progressive";

  const lesson = {
    ts: new Date().toISOString(),
    coherence,
    insightExcerpt: latestInsight.slice(0, 200),
    reflectionExcerpt: latestReflection.slice(0, 200),
    summary: `Matilda identifies a ${coherence.toLowerCase()} phase: ${latestInsight} | ${latestReflection}`,
  };

  fs.mkdirSync(path.dirname(cohesionFile), { recursive: true });
  fs.appendFileSync(cohesionFile, JSON.stringify(lesson) + "\n", "utf8");
  return lesson;
}

/** Retrieve stored cohesion lessons */
export function getCognitiveHistory(limit = 20) {
  if (!fs.existsSync(cohesionFile)) return [];
  const lines = fs.readFileSync(cohesionFile, "utf8").trim().split("\n").slice(-limit);
  return lines.map(l => JSON.parse(l));
}
