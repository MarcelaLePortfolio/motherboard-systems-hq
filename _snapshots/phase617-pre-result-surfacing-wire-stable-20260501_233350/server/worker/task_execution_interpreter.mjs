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

  const executionMode = payload.execution_mode || "standard";
  const cachePolicy = payload.cache_policy || "reuse";
  const memoryScope = payload.memory_scope || "preserve";

  const isPolicyAware =
    executionMode === "rebuild_context" ||
    cachePolicy === "bypass" ||
    memoryScope === "reset_partial";

  if (isPolicyAware) {
    const notes = [
      executionMode === "rebuild_context" ? "fresh context requested" : null,
      cachePolicy === "bypass" ? "cache bypass observed" : null,
      memoryScope === "reset_partial" ? "partial memory reset observed" : null
    ].filter(Boolean).join("; ");

    return {
      ok: true,
      strategy_applied: "prompt_augmentation",
      notes,
      output: `Policy-aware execution prepared for: ${title}`,
      meta: {
        ...meta,
        execution_mode: executionMode,
        cache_policy: cachePolicy,
        memory_scope: memoryScope
      }
    };
  }

  if (meta?.retry_mode === "strategy_shift") {
    return {
      ok: true,
      strategy_applied: "prompt_augmentation",
      notes: meta.instruction || "strategy shift applied",
      output: `Strategy-shift execution prepared for: ${title}`,
      meta
    };
  }

  return {
    ok: true,
    strategy_applied: "default",
    notes: "standard execution path",
    output: `Standard execution prepared for: ${title}`,
    meta
  };
}
