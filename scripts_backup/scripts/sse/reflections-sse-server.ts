import express from "express"



// <0001fb40> Phase 9.15 — Reflections SSE Cinematic 1 Hz Flow

import cors from "cors";

const app = express();
app.use(cors());
const PORT = 3101;

const reflections = [
  "<0001fa9e> Matilda whispers: 'Stability confirmed. Streams aligned.'",
  "<0001fa9e> Cade hums: 'Processing in perfect rhythm...'",
  "<0001fa9e> Effie smiles: 'Heartbeat synchronized with dashboard feed.'",
  "<0001fa9e> Atlas murmurs: 'All agents within operational variance.'",
  "<0001fa9e> Reflections shimmer: 'The system breathes at one hertz.'"
];

app.get("/events/reflections", (req: express.Request, res: express.Response) => {
  (<any>res).set({
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
    "Access-Control-Allow-Origin": "*",
  });
  (<any>res).flushHeaders();

  res.write(`data: <0001fa9e> Reflections SSE stream initialized at ${new Date().toISOString()}\n\n`);

  let i = 0;
  const interval = setInterval(() => {
    const msg = reflections[i % reflections.length];
    res.write(`data: ${msg}\n\n`);
    i++;
  }, 1000); // 1 Hz cadence

  req.on("close", () => {
    clearInterval(interval);
    console.log("❌ Client disconnected from Reflections SSE");
  });
});

app.listen(PORT, () => {
  console.log(`✅ Reflections SSE server running at 1 Hz cinematic flow (port ${PORT})`);
});

// <0001fbe0> Phase 9.20 — Add /events/agents SSE JSON feed
app.get("/events/agents", (req: express.Request, res: express.Response) => {
  (<any>res).set({
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
    "Access-Control-Allow-Origin": "*",
  });
  (<any>res).flushHeaders();

  const agents = ["Matilda", "Cade", "Effie", "OPS", "Reflections"];

  res.write(`data: ${JSON.stringify(Object.fromEntries(agents.map(a => [a, "online"])))}\n\n`);

  const interval = setInterval(() => {
    res.write(`data: ${JSON.stringify(Object.fromEntries(agents.map(a => [a, "online"])))}\n\n`);
  }, 5000); // update every 5s

  req.on("close", () => clearInterval(interval));
});
