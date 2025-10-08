import fs from "fs";
import path from "path";

const auditFile = path.resolve("db/audit.jsonl");
const reflectionFile = path.resolve("db/reflections.jsonl");
const lessonFile = path.resolve("db/lessons.jsonl");
const cohesionFile = path.resolve("db/cohesion.jsonl");
const simulationFile = path.resolve("db/introspectiveSim.jsonl");

function readLines(file: string, limit = 100) {
  if (!fs.existsSync(file)) return [];
  const lines = fs.readFileSync(file, "utf8").trim().split("\n").slice(-limit);
  return lines.map(l => JSON.parse(l));
}

/** Simulate internal scenario based on trends */
export function runIntrospectiveSimulation(scenario: string = "optimize performance") {
  const audits = readLines(auditFile, 100);
  const reflections = readLines(reflectionFile, 50);
  const lessons = readLines(lessonFile, 50);
  const cohesion = readLines(cohesionFile, 50);

  const totalEvents = audits.length;
  const recentErrors = audits.filter((a: any) => a.event?.includes("error")).length;
  const errorRate = totalEvents ? ((recentErrors / totalEvents) * 100).toFixed(1) : "0";

  const reflectionThemes = reflections.map((r: any) => r.feedback).slice(-3).join(" | ");
  const lessonSummaries = lessons.map((l: any) => l.synthesizedInsight).slice(-2).join(" | ");
  const cohesionStates = cohesion.map((c: any) => c.coherence).slice(-5).join(", ");

  const simulatedOutcome = {
    scenario,
    predictedSuccess: `${(100 - Number(errorRate) / 2).toFixed(1)}%`,
    predictedRisk: `${errorRate}%`,
    trendContext: cohesionStates || "Stable",
    rationale: `Based on ${totalEvents} recent events, ${recentErrors} errors (${errorRate}%). Reflection themes suggest: ${reflectionThemes}. Lessons: ${lessonSummaries}.`,
  };

  const entry = { ts: new Date().toISOString(), ...simulatedOutcome };
  fs.mkdirSync(path.dirname(simulationFile), { recursive: true });
  fs.appendFileSync(simulationFile, JSON.stringify(entry) + "\n", "utf8");
  return entry;
}

/** Retrieve stored simulations */
export function getSimulations(limit = 20) {
  if (!fs.existsSync(simulationFile)) return [];
  const lines = fs.readFileSync(simulationFile, "utf8").trim().split("\n").slice(-limit);
  return lines.map(l => JSON.parse(l));
}
