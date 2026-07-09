
import express from "express";

import { getEvents } from "../events/execution-event-bus";

const router = express.Router();

/**

 * STATE SURFACE LAYER

 * Converts raw event bus into UI-safe stream format

 */

router.get("/events/surface", (_, res) => {

  const events = getEvents();

  const normalized = events.map((e: any) => ({

    domain: e.source || "unknown",

    type: e.type || "event",

    message: e.message || e.type,

    timestamp: e.timestamp || Date.now(),

    severity: e.severity || "info"

  }));

  res.json({

    ok: true,

    events: normalized

  });

});

export default router;

