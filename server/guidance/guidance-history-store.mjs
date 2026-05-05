import fs from "node:fs";
import path from "node:path";

const DEFAULT_HISTORY_PATH = path.resolve(
  process.cwd(),
  process.env.GUIDANCE_HISTORY_JSONL_PATH || "data/guidance-history.jsonl"
);

function ensureParentDir(filePath = DEFAULT_HISTORY_PATH) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

export function appendGuidanceEvents(events = [], filePath = DEFAULT_HISTORY_PATH) {
  if (!Array.isArray(events) || events.length === 0) {
    return { ok: true, written: 0, source: "jsonl" };
  }

  try {
    ensureParentDir(filePath);

    const lines = events
      .filter(Boolean)
      .map((event) =>
        JSON.stringify({
          timestamp: event.timestamp || new Date().toISOString(),
          task_id: event.task_id || "global",
          subsystem: event.subsystem || "guidance",
          signal_type: event.signal_type || "generic",
          severity: event.severity || "info",
          message: event.message || "",
        })
      )
      .join("\n");

    if (!lines) {
      return { ok: true, written: 0, source: "jsonl" };
    }

    fs.appendFileSync(filePath, `${lines}\n`, "utf8");

    return { ok: true, written: events.length, source: "jsonl" };
  } catch (error) {
    console.warn("[guidance-history-store-write-failed]", error?.message || error);

    return {
      ok: false,
      written: 0,
      source: "memory-fallback",
      error: "guidance_history_jsonl_write_failed",
    };
  }
}

export function readRecentGuidanceEvents(limit = 250, filePath = DEFAULT_HISTORY_PATH) {
  try {
    if (!fs.existsSync(filePath)) {
      return { ok: true, source: "jsonl", events: [] };
    }

    const raw = fs.readFileSync(filePath, "utf8").trim();

    if (!raw) {
      return { ok: true, source: "jsonl", events: [] };
    }

    const events = raw
      .split("\n")
      .filter(Boolean)
      .slice(-Math.max(1, Number(limit) || 250))
      .map((line) => JSON.parse(line))
      .filter(Boolean);

    return { ok: true, source: "jsonl", events };
  } catch (error) {
    console.warn("[guidance-history-store-read-failed]", error?.message || error);

    return {
      ok: false,
      source: "memory-fallback",
      events: [],
      error: "guidance_history_jsonl_read_failed",
    };
  }
}

export default {
  appendGuidanceEvents,
  readRecentGuidanceEvents,
};
