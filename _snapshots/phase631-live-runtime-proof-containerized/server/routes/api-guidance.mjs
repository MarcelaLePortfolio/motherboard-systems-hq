import express from "express";

const router = express.Router();

// PHASE 510 — GUIDANCE ROUTE (ACTIVE ROUTER, NO INFERENCE)
router.get("/", (req, res) => {
  try {
    const hasRequest = req.query?.request || req.body?.request;

    if (!hasRequest) {
      return res.json({
        guidance_available: false,
        guidance: null,
        reason: "no_request_provided"
      });
    }

    return res.json({
      guidance_available: true,
      guidance: {
        status: "generated",
        input: hasRequest,
        steps: [
          "intake_received",
          "governance_not_evaluated",
          "execution_not_started"
        ],
        note: "minimal_deterministic_guidance_stream"
      },
      evidence: [],
      reason: "request_detected"
    });
  } catch (e) {
    return res.status(500).json({
      guidance_available: false,
      guidance: null,
      reason: "runtime_error"
    });
  }
});

export default router;
