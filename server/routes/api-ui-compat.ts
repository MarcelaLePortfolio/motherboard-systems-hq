
import express from "express";

export function mountApiUiCompat(app: express.Express) {

  app.get("/api/tasks", (_req, res) => {

    res.json({ tasks: [] });

  });

  app.get("/api/agent-status", (_req, res) => {

    res.json({ status: "ok", agents: [] });

  });

  app.get("/api/guidance-history", (_req, res) => {

    res.json({ history: [] });

  });

}

