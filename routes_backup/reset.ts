import express, { Request, Response } from "express";
const router = express.Router();






// <0001faf2> Phase 6.4 — Reset Endpoint

import { resetRoundtrip } from "../scripts/reset-roundtrip";


  try {
    resetRoundtrip();
    res.json({ status: "ok", message: "System reset completed successfully." });
  } catch (err) {
    console.error("❌ Reset endpoint error:", err);
    res.status(500).json({ status: "error", message: err.message });
  }
});

