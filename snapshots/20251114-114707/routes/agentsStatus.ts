import express from "express";
export const agentsStatusRouter = express.Router();

agentsStatusRouter.get("/", (_req, res) => {
  res.json({
    ok: true,
    timestamp: new Date().toISOString(),
    message: "<0001fa7f> Agents Status route active",
    agents: [
      { name: "Matilda", status: "🟢 online" },
      { name: "Cade", status: "🟢 online" },
      { name: "Effie", status: "🟡 idle" }
    ]
  });
});
