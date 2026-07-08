
import express from "express";

import { getEvents } from "../../events/execution-event-bus";

import { reconstructWhy } from "../../atlas/atlas-reconstruction-model";

const router = express.Router();

router.get("/atlas/why", (req, res) => {

  const events = getEvents();

  const result = reconstructWhy(req.query.intent, events);

  res.json({

    status: "ok",

    atlas: result,

    eventCount: events.length

  });

});

export default router;

