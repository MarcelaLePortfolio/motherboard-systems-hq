// <0001fbC2> matilda-router – minimal chatbot endpoint
import express from "express";

const router = express.Router();

router.post("/", express.json(), (req, res) => {
  const user = req.body?.message || "(no message)";
  res.json({
    ok: true,
    reply: `🤖 Matilda received: "${user}"`
  });
});

export default router;
