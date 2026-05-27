import express, { Request, Response } from "express";
const router = express.Router();








persistentInsight.get("/", (_req, res) => {
  res.json({
    ok: true,
    timestamp: new Date().toISOString(),
    message: "<0001fa7b> Persistent Insight route active"
  });
});
