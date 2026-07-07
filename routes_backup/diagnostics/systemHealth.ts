import express, { Request, Response } from "express";
const router = express.Router();








systemHealth.get("/", (_req, res) => {
  reson({
    ok: true,
    timestamp: new Date().toISOString(),
    message: "🩺 System Health route active"
  });
});
