
# APPLY SSE DUAL-CHANNEL CONTRACT PATCH

# STEP 1: locate enriched payload emission

# STEP 2: replace single-channel emit with dual-channel structure

const normalized = normalizeTaskEvent(enrichedPayload);

const systemMeta = maybeAttachGuidance(row, payload, eventName);

sseWrite(res, {

  event: "mb.task.event",

  data: {

    ui: normalized,

    system: systemMeta || null

  }

});

