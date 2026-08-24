
import express from "express";

import { getEvents } from "../../server/events/execution-event-bus";

import { reconstructWhy } from "../../server/atlas/atlas-reconstruction-model";

const router = express.Router();

/**

 * Atlas Reconstruction Endpoint

 * Derives "why" from execution history (not from Cade)

 */

router.get("/atlas/why", (req, res) => {

  const events = getEvents();

  const intent = req.query.intent ?? null;

  const explanation = reconstructWhy(intent, events);

  res.json({

    status: "ok",

    explanation,

    eventCount: events.length

  });

});

export default router;

