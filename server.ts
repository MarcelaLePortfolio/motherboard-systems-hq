import express from "express";
import { matildaHandler } from "./scripts/agents/matilda-handler";

const app = express();
app.use(express.json());

app.get("/health", (_req, res) => res.json({ status: "ok" }));

app.post("/matilda", async (req, res) => {
  const { command, payload, actor } = req.body;
  const result = await matildaHandler(command, payload, actor);
  res.json(result);
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`✅ Server listening on http://localhost:${PORT}`);
  console.log("Mounted: GET /health, POST /matilda, static /public");
});
