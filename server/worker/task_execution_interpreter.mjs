function unwrapPayload(value) {
  if (!value) return {};
  if (typeof value === "object") return value;
  try {
    return JSON.parse(String(value));
  } catch {
    return {};
  }
}

function extractMeta(task = {}) {
  const payload = unwrapPayload(task.payload);
  return payload?.meta || task?.meta || {};
}

export function interpretTaskExecution(task = {}) {
  const payload = unwrapPayload(task.payload);
  const meta = extractMeta(task);
  const title = task.title || payload.title || "Untitled task";

  if (meta?.retry_mode === "strategy_shift") {
    return {
      ok: true,
      strategy_applied: "prompt_augmentation",
      notes: meta.instruction || "strategy shift applied",
      output: `Strategy-shift execution prepared for: ${title}`,
      meta,
    };
  }

  return {
    ok: true,
    strategy_applied: "default",
    notes: "standard execution path",
    output: `Standard execution prepared for: ${title}`,
    meta,
  };
}
