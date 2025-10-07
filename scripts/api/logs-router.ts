import express from "express";
const router = express.Router();

router.get("/recent", (_req, res) => {
  const now = Date.now();
  res.json([
    { ts: now, event: "Matilda initialized." },
    { ts: now, event: "Cade executed task 001 successfully." }
  ]);
});

export default router;
