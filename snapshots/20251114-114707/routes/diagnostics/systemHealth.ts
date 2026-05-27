import express from "express";
export const systemHealth = express.Router();

systemHealth.get("/", (_req, res) => {
  res.json({
    ok: true,
    timestamp: new Date().toISOString(),
    message: "🩺 System Health route active"
  });
});
