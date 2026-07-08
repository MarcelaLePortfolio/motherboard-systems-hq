
import express from "express";

import { getEvents } from "../../events/execution-event-bus";

import { runAtlasIntelligence } from "../../atlas/atlas-unified-engine";

const router = express.Router();

/**

 * Atlas Intelligence API

 * Single endpoint for full system reasoning

 */

router.get("/atlas/analyze", (req, res) => {

  const events = getEvents();

  const result = runAtlasIntelligence(events);

  res.json({

    status: "ok",

    ...result

  });

});

export default router;

