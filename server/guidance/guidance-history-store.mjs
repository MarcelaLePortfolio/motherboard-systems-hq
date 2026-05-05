import fs from "node:fs";
import path from "node:path";

const DEFAULT_HISTORY_PATH = path.resolve(
  process.cwd(),
  process.env.GUIDANCE_HISTORY_JSONL_PATH || "data/guidance-history.jsonl"
);

const DEFAULT_MAX_LINES = Math.max(
  1,
  Number(process.env.GUIDANCE_HISTORY_MAX_LINES || 1000)
);

function ensureParentDir(filePath = DEFAULT_HISTORY_PATH) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

function applyLineRetention(filePath = DEFAULT_HISTORY_PATH, maxLines = DEFAULT_MAX_LINES) {
  try {
    if (!fs.existsSync(filePath)) {
      return { ok: true, retained: 0, max_lines: maxLines };
    }

    const raw = fs.readFileSync(filePath, "utf8");
    const lines = raw.split("\n").filter(Boolean);

    if (lines.length <= maxLines) {
      return { ok: true, retained: lines.length, max_lines: maxLines };
    }

    const retained = lines.slice(-maxLines);
    const tmpPath = `${filePath}.tmp`;

    fs.writeFileSync(tmpPath, `${retained.join("\n")}\n`, "utf8");
    fs.renameSync(tmpPath, filePath);

    return { ok: true, retained: retained.length, max_lines: maxLines };
  } catch (error) {
    console.warn("[guidance-history-retention-failed]", error?.message || error);

    return {
      ok: false,
      retained: null,
      max_lines: maxLines,
      error: "guidance_history_retention_failed",
    };
  }
}

export function appendGuidanceEvents(events = [], filePath = DEFAULT_HISTORY_PATH) {
  if (!Array.isArray(events) || events.length === 0) {
    return { ok: true, written: 0, source: "jsonl", retention: { ok: true, retained: 0, max_lines: DEFAULT_MAX_LINES } };
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
      return { ok: true, written: 0, source: "jsonl", retention: { ok: true, retained: 0, max_lines: DEFAULT_MAX_LINES } };
    }

    fs.appendFileSync(filePath, `${lines}\n`, "utf8");

    const retention = applyLineRetention(filePath);

    return { ok: true, written: events.length, source: "jsonl", retention };
  } catch (error) {
    console.warn("[guidance-history-store-write-failed]", error?.message || error);

    return {
      ok: false,
      written: 0,
      source: "memory-fallback",
      error: "guidance_history_jsonl_write_failed",
      retention: {
        ok: false,
        retained: null,
        max_lines: DEFAULT_MAX_LINES,
        error: "guidance_history_write_failed_before_retention",
      },
    };
  }
}

export function readRecentGuidanceEvents(limit = 250, filePath = DEFAULT_HISTORY_PATH) {
  try {
    if (!fs.existsSync(filePath)) {
      return { ok: true, source: "jsonl", events: [], max_lines: DEFAULT_MAX_LINES };
    }

    const raw = fs.readFileSync(filePath, "utf8").trim();

    if (!raw) {
      return { ok: true, source: "jsonl", events: [], max_lines: DEFAULT_MAX_LINES };
    }

    const events = raw
      .split("\n")
      .filter(Boolean)
      .slice(-Math.max(1, Number(limit) || 250))
      .map((line) => JSON.parse(line))
      .filter(Boolean);

    return { ok: true, source: "jsonl", events, max_lines: DEFAULT_MAX_LINES };
  } catch (error) {
    console.warn("[guidance-history-store-read-failed]", error?.message || error);

    return {
      ok: false,
      source: "memory-fallback",
      events: [],
      max_lines: DEFAULT_MAX_LINES,
      error: "guidance_history_jsonl_read_failed",
    };
  }
}

export default {
  appendGuidanceEvents,
  readRecentGuidanceEvents,
};
