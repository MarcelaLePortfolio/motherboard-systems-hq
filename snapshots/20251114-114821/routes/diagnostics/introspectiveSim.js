import express from "express";
const router = express.Router();

router.get("/", (req, res) => {
  res.json({
    reflection: "Self-check complete.",
    outcomes: [],
    timestamp: new Date().toISOString()
  });
});

export default router;
