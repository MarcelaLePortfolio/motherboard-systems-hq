import express from "express";
import { runIntrospectiveSimulation, getSimulations } from "../pipelines/introspectiveSim";

const router = express.Router();

/** POST /introspect/run — perform simulated scenario */
router.post("/run", (req, res) => {
  try {
    const { scenario } = req.body || {};
    const sim = runIntrospectiveSimulation(scenario);
    res.json({ ok: true, sim });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

/** GET /introspect/history — retrieve past simulations */
router.get("/history", (_req, res) => {
  try {
    const sims = getSimulations(50);
    res.json({ ok: true, sims });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
