import express from "express";
const router = express.Router();

router.get("/", (req, res) => {
  res.json({
    Matilda: { status: "🟢 online" },
    Cade: { status: "🟡 standby" },
    Effie: { status: "�� online" }
  });
});

export default router;
