import express from "express";
const router = express.Router();

router.get("/recent", (_req, res) => {
  const now = Date.now();
  res.json([
    { ts: now, command: "Write to file", status: "Complete" },
    { ts: now, command: "Summarize logs", status: "In Progress" }
  ]);
});

export default router;
