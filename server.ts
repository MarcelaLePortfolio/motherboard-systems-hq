// <0001fae6> Phase 9.6.2 — Dashboard Port Lock (3000)
import express from "express";
import path from "path";
import { PORTS } from "./config/ports";

const app = express();

// Serve static dashboard + assets
app.use(express.static(path.join(process.cwd(), "public")));
import { router as matildaRouter } from "./routes/matilda";
app.use(express.json());
app.use("/matilda", matildaRouter);
import { router as delegateRouter } from "./routes/delegate";
app.use("/delegate", delegateRouter);




// Optional health check
app.get("/health", (_, res) => res.send("OK"));

// Start dashboard + API server
app.listen(PORTS.DASHBOARD, () => {
  console.log(`🖥️ Dashboard + API server locked on http://localhost:${PORTS.DASHBOARD}`);
});
