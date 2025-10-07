import fs from "fs";
import path from "path";
import { captureNewInsight } from "../pipelines/persistentInsight";
import { runAutonomicAudit } from "../pipelines/autonomicFeedback";
import { runReflectiveSynthesis } from "../pipelines/reflectiveFeedback";

type Task = {
  id: string;
  action: "insight.persist" | "autonomic.feedback" | "reflective.synthesis";
  intervalSec: number;
  enabled: boolean;
  lastRun?: string | null;
  nextRun?: string | null;
  note?: string;
};

const storeFile = path.resolve("db/scheduler.json");
const auditFile = path.resolve("db/audit.jsonl");

const timers: Record<string, NodeJS.Timeout> = {};
let tasks: Task[] = [];

function audit(event: string, payload: any = {}, status: "ok" | "error" = "ok", result?: any) {
  const line = JSON.stringify({ ts: new Date().toISOString(), event, status, payload, result });
  fs.mkdirSync(path.dirname(auditFile), { recursive: true });
  fs.appendFileSync(auditFile, line + "\n", "utf8");
}

function save() {
  fs.mkdirSync(path.dirname(storeFile), { recursive: true });
  fs.writeFileSync(storeFile, JSON.stringify(tasks, null, 2), "utf8");
}

function load(): Task[] {
  if (!fs.existsSync(storeFile)) return [];
  try {
    const raw = fs.readFileSync(storeFile, "utf8");
    return JSON.parse(raw) as Task[];
  } catch {
    return [];
  }
}

function computeNextRun(intervalSec: number) {
  return new Date(Date.now() + intervalSec * 1000).toISOString();
}

async function runAction(action: Task["action"]) {
  switch (action) {
    case "insight.persist":
      return captureNewInsight();
    case "autonomic.feedback":
      return runAutonomicAudit();
    case "reflective.synthesis":
      return runReflectiveSynthesis();
    default:
      throw new Error("Unknown action: " + action);
  }
}

function scheduleTask(t: Task) {
  clearTaskTimer(t.id);
  if (!t.enabled) return;

  const runner = async () => {
    try {
      const result = await runAction(t.action);
      t.lastRun = new Date().toISOString();
      t.nextRun = computeNextRun(t.intervalSec);
      save();
      audit("scheduler.run", { id: t.id, action: t.action }, "ok", result);
    } catch (e: any) {
      audit("scheduler.error", { id: t.id, action: t.action, error: e?.message ?? String(e) }, "error");
    }
  };

  t.nextRun = computeNextRun(t.intervalSec);
  timers[t.id] = setInterval(runner, t.intervalSec * 1000);
}

function clearTaskTimer(id: string) {
  if (timers[id]) {
    clearInterval(timers[id]);
    delete timers[id];
  }
}

export function loadSchedules() {
  tasks = load();
  tasks.forEach(scheduleTask);
  audit("scheduler.loaded", { count: tasks.length }, "ok");
}

export function listSchedules() {
  return tasks;
}

export function createOrUpdateSchedule(task: Task) {
  const idx = tasks.findIndex(x => x.id === task.id);
  if (idx >= 0) {
    tasks[idx] = { ...tasks[idx], ...task };
  } else {
    tasks.push(task);
  }
  save();
  scheduleTask(task);
  audit("scheduler.upsert", { id: task.id, action: task.action, intervalSec: task.intervalSec, enabled: task.enabled }, "ok");
  return task;
}

export function enableSchedule(id: string) {
  const t = tasks.find(x => x.id === id);
  if (!t) throw new Error("Task not found: " + id);
  t.enabled = true;
  save();
  scheduleTask(t);
  return t;
}

export function disableSchedule(id: string) {
  const t = tasks.find(x => x.id === id);
  if (!t) throw new Error("Task not found: " + id);
  t.enabled = false;
  save();
  clearTaskTimer(id);
  return t;
}

export async function runNow(id: string) {
  const t = tasks.find(x => x.id === id);
  if (!t) throw new Error("Task not found: " + id);
  const result = await runAction(t.action);
  t.lastRun = new Date().toISOString();
  t.nextRun = computeNextRun(t.intervalSec);
  save();
  audit("scheduler.runNow", { id: t.id, action: t.action }, "ok", result);
  return result;
}

export function ensureDefaultSchedules() {
  const defaults: Task[] = [
    { id: "persist-insight-hourly", action: "insight.persist", intervalSec: 3600, enabled: true, note: "Persist Matilda insights hourly" },
    { id: "autonomic-feedback-6h", action: "autonomic.feedback", intervalSec: 21600, enabled: true, note: "Cade self-audit every 6 hours" },
    { id: "reflective-synthesis-nightly", action: "reflective.synthesis", intervalSec: 86400, enabled: true, note: "Nightly reflective synthesis" },
  ];

  for (const d of defaults) {
    const exists = tasks.some(t => t.id === d.id);
    if (!exists) {
      tasks.push({ ...d, lastRun: null, nextRun: computeNextRun(d.intervalSec) });
      scheduleTask(d);
      audit("scheduler.defaultCreated", { id: d.id, action: d.action }, "ok");
    }
  }
  save();
}
