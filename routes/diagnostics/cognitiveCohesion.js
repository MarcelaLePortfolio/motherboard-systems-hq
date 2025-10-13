import express from "express";
const router = express.Router();

router.get("/", (req, res) => {
  res.json({
    module: "cognitiveCohesion",
    status: "✅ Operational",
    uptime: process.uptime().toFixed(2)
  });
});

export default router;
