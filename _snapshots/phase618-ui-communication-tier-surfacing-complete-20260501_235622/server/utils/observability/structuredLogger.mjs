// NON-INVASIVE STRUCTURED LOGGER
// Safe: wraps console output only, does NOT touch execution paths

export function structuredLog(event, payload = {}) {
  try {
    const log = {
      ts: new Date().toISOString(),
      event,
      ...payload,
    };

    console.log("OBS_EVENT", JSON.stringify(log));
  } catch (err) {
    // fail silently to preserve execution safety
    console.warn("OBS_LOG_FAIL", err?.message);
  }
}

// Example usage (DO NOT inject into execution paths):
// structuredLog("retry.invoked", { mode: "standard", taskId: "123" });
