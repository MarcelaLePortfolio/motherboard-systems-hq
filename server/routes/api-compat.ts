
import { Express } from "express";

export function mountApiCompat(app: Express) {

  app.get("/api/tasks", (_req, res) => {

    res.json({ tasks: [] });

  });

  app.get("/api/agent-status", (_req, res) => {

    res.json({

      status: "ok",

      agents: []

    });

  });

  app.get("/api/guidance", (_req, res) => {

    res.json({

      guidance_available: false,

      guidance: "offline"

    });

  });

  app.get("/api/guidance-history", (_req, res) => {

    res.json({ history: [] });

  });

  app.get("/api/tasks/history", (_req, res) => {

    res.json({ tasks: [] });

  });

  // SSE fallback so frontend stops crashing

  app.get("/events/ops", (_req, res) => {

    res.setHeader("Content-Type", "text/event-stream");

    res.write("data: {}\n\n");

    res.end();

  });

  app.get("/events/reflections", (_req, res) => {

    res.setHeader("Content-Type", "text/event-stream");

    res.write("data: {}\n\n");

    res.end();

  });

}

