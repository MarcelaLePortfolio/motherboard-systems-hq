import express from "express";
import path from "path";
import cognitiveCohesion from "./routes/diagnostics/cognitiveCohesion.js";
import insightVisualizer from "./routes/diagnostics/insightVisualizer.js";

/**
 * <0001fab9> Diagnostics Routes — Final Mount Order Verified
 */
export function setupApp() {
  const app = express();

  // ✅ Core test route
  app.get("/test", (_, res) => res.json({ ok: true, message: "Express core active" }));

  // ✅ Mount diagnostics before static
  app.use("/diagnostics/cognitive-cohesion", cognitiveCohesion);
  app.use("/diagnostics/insight-visualizer", insightVisualizer);
  console.log("🧠 Diagnostics routes mounted before static middleware.");

  // ✅ Mount static middleware last
  const staticRoot = path.join(process.cwd(), "public");
  app.use("/", express.static(staticRoot));
  console.log("📦 Static middleware mounted last.");

  return app;
}
