import express from "express";
const router = express.Router();

router.get("/agents", (_req, res) => {
  const now = Date.now();
  res.json([
    { id: "cade", name: "Cade", status: "Online", lastSeen: now },
    { id: "matilda", name: "Matilda", status: "Online", lastSeen: now }
  ]);
});

export default router;
