// <0001faf2> Phase 6.4 — Reset Endpoint
import express from "express";
import { resetRoundtrip } from "../scripts/reset-roundtrip";

const router = express.Router();

router.post("/", async (_req, res) => {
  try {
    resetRoundtrip();
    res.json({ status: "ok", message: "System reset completed successfully." });
  } catch (err) {
    console.error("❌ Reset endpoint error:", err);
    res.status(500).json({ status: "error", message: err.message });
  }
});

export default router;
