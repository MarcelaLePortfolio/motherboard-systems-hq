import express from "express";
const router = express.Router();

router.get("/", (req, res) => {
  res.json({
    entries: [
      { id: 1, event: "System initialized", level: "info", at: new Date().toISOString() }
    ]
  });
});

export default router;
