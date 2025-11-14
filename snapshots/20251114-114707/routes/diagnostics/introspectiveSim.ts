import express from "express";
export const introspectiveSim = express.Router();

introspectiveSim.get("/", (_req, res) => {
  res.json({
    ok: true,
    timestamp: new Date().toISOString(),
    message: "<0001fa7d> Introspective Simulation route active"
  });
});
