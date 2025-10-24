const express = require("express");
const router = express.Router();

// <0001fa95> Stub endpoint — consistent JSON format
router.get("/", (_, res) => {
  res.json({
    ok: true,
    timestamp: new Date().toISOString(),
    message: "🎨 Insight Visualizer route active"
  });
});

module.exports = router;
