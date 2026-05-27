import express, { Request, Response } from "express";
const router = express.Router();








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
