import express from "express";
import { registerDynamicEndpoint } from "../utils/registerDynamicEndpoint";

const router = express.Router();

/**
 * POST /registry/mount
 * --------------------
 * Registers a new skill endpoint live on the *running* Express instance.
 */
router.post("/mount", async (req, res) => {
  try {
    const { skill } = req.body || {};
    if (!skill) return res.status(400).json({ ok: false, error: "Missing skill name" });

    const app = req.app; // attach directly to current server
    await registerDynamicEndpoint(app, skill);

    res.json({ ok: true, message: `🛰️ Skill '${skill}' mounted live.` });
  } catch (err: any) {
    console.error("❌ Registry mount error:", err.message);
    res.status(500).json({ ok: false, error: err.message });
  }
});

export default router;
