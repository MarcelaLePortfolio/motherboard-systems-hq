import express from "express";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";
import { runMatildaStub } from "./matilda-chat-stub.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(cors());
app.use(express.json());

// --------------------
// Matilda Chat Pipeline (stub)
// --------------------
app.post("/api/chat", async (req, res) => {
try {
const body = req.body || {};
const rawMessage = typeof body.message === "string" ? body.message : "";
const message = rawMessage.trim();

```
if (!message) {
  return res.status(400).json({
    ok: false,
    error: "Missing or invalid 'message'.",
  });
}

const result = await runMatildaStub({
  message,
  agent: body.agent || "matilda",
});

return res.json(result);
```

} catch (err) {
console.error("[server.mjs:/api/chat] Error:", err);
return res.status(500).json({
ok: false,
error: "Matilda stub pipeline encountered an error.",
});
}
});

// --------------------
// STATIC + DASHBOARD
// --------------------
app.use(express.static(path.join(__dirname, "public")));

function sendDashboard(_req, res) {
res.sendFile(path.join(__dirname, "public", "dashboard.html"));
}

app.get("/dashboard", sendDashboard);
app.get("/", sendDashboard);

// --------------------
// START SERVER
// --------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
console.log(`[server.mjs] Listening on port ${PORT}`);
});
