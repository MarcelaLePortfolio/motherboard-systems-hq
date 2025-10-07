import fs from "fs";
import path from "path";

const reflectionsFile = path.resolve("db/reflections.jsonl");
const lessonsFile = path.resolve("db/lessons.jsonl");

/** Utility: read JSONL safely */
function readLines(file: string, limit = 100): any[] {
  if (!fs.existsSync(file)) return [];
  return fs.readFileSync(file, "utf8")
    .trim()
    .split("\n")
    .slice(-limit)
    .map(l => {
      try { return JSON.parse(l); } catch { return null; }
    })
    .filter(Boolean);
}

/** Basic NLP-style classification heuristic */
function categorizeFeedback(text: string): string {
  const lower = text.toLowerCase();
  if (lower.includes("error") || lower.includes("regenerate")) return "Maintenance";
  if (lower.includes("stable") || lower.includes("no immediate action")) return "Performance";
  if (lower.includes("insight") || lower.includes("themes")) return "Learning";
  return "General";
}

/** Extract trends across reflections */
function extractTrends(reflections: any[]) {
  const categories: Record<string, number> = {};
  for (const r of reflections) {
    const c = categorizeFeedback(r.feedback);
    categories[c] = (categories[c] || 0) + 1;
  }
  const total = reflections.length || 1;
  const dominant = Object.entries(categories).sort((a, b) => b[1] - a[1])[0]?.[0] ?? "General";
  const summary = Object.entries(categories)
    .map(([k, v]) => `${k}: ${(v / total * 100).toFixed(0)}%`)
    .join(", ");
  return { categories, dominant, summary };
}

/** Generate reflective summary */
export function runReflectiveSynthesis() {
  const reflections = readLines(reflectionsFile, 100);
  if (!reflections.length) throw new Error("No reflections found.");

  const trends = extractTrends(reflections);
  const lesson = {
    ts: new Date().toISOString(),
    dominant: trends.dominant,
    trendSummary: trends.summary,
    reflectionsAnalyzed: reflections.length,
    synthesizedInsight: `Matilda concludes the system is showing predominant ${trends.dominant.toLowerCase()} patterns. Summary: ${trends.summary}.`,
  };

  fs.mkdirSync(path.dirname(lessonsFile), { recursive: true });
  fs.appendFileSync(lessonsFile, JSON.stringify(lesson) + "\n", "utf8");
  return lesson;
}

/** Retrieve stored lessons */
export function getLessons(limit = 20) {
  if (!fs.existsSync(lessonsFile)) return [];
  const lines = fs.readFileSync(lessonsFile, "utf8").trim().split("\n").slice(-limit);
  return lines.map(l => JSON.parse(l));
}
