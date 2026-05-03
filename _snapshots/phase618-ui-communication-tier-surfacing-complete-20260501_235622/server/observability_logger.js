function emitEvent(event) {
  try {
    console.log("[OBS_EVENT]", JSON.stringify({
      ts: Date.now(),
      ...event
    }));
  } catch (err) {
    console.error("[OBS_EVENT_ERROR]", err);
  }
}

module.exports = { emitEvent };
