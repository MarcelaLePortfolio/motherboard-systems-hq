import express from "express";
const router = express.Router();
router.get("/", (_req, res) => {
    res.json({
        ok: true,
        status: "OK",
        service: "Motherboard Systems HQ",
        corridor: "Phase 487",
        mode: "stable-base",
        diagnostics: {
            tasksRoute: "active",
            logsRoute: "active",
            delegateRoute: "active",
            matildaRoute: "local-safe-mode",
        },
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        memory: process.memoryUsage(),
    });
});
export default router;
