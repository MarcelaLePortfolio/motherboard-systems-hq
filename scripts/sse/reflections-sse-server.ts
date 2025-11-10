// <0001fb20> Phase 10.13 — Reflections SSE Server Reconstruction
import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
const PORT = 3101;

app.get("/events/reflections", (req, res) => {
  res.set({
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
    "Access-Control-Allow-Origin": "*",
  });
  res.flushHeaders();

  res.write(`data: 🪞 Reflections SSE stream initialized at ${new Date().toISOString()}\n\n`);

  const interval = setInterval(() => {
    res.write(`data: Reflection heartbeat ${new Date().toISOString()}\n\n`);
  }, 5000);

  req.on("close", () => {
    clearInterval(interval);
    console.log("❌ Client disconnected from Reflections SSE");
  });
});

app.listen(PORT, () => {
  console.log(`✅ Reflections SSE server running on port ${PORT}`);
});
