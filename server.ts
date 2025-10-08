// <0001fbC1> Serve real dashboard layout from public/
import express from "express";
import introspectiveRouter from "./scripts/api/introspective-router";
import adaptationRouter from "./scripts/api/adaptation-router";
import insightVisualizerRouter from "./scripts/api/insight-visualizer-router";
import { getApp } from "./scripts/utils/appSingleton";
const app = getApp();

import systemHealthRouter from "./scripts/api/system-health-router";
import cognitiveRouter from "./scripts/api/cognitive-router";
import schedulerRouter from "./scripts/api/scheduler-router";
import { loadSchedules, ensureDefaultSchedules } from "./scripts/scheduler/engine";
import reflectiveFeedbackRouter from "./scripts/api/reflective-feedback-router";
import autonomicFeedbackRouter from "./scripts/api/autonomic-feedback-router";
import cadeRouter from "./scripts/api/cade-router";
import opsRouter from "./scripts/api/ops-router";
import insightRouter from "./scripts/api/insight-router";
import insightPersistentRouter from "./scripts/api/insight-persistent-router";
import reflectionsRouter from "./scripts/api/reflections-router";
import matildaRouter from "./scripts/api/matilda-router";
import statusRouter from "./scripts/api/status-router";
import tasksRouter from "./scripts/api/tasks-router";
import logsRouter from "./scripts/api/logs-router";
import path from "path";
import chronicleRouter from "./scripts/api/chronicle-router";
import registryRouter from "./scripts/api/registry-router";
import { registerDynamicEndpoint } from "./scripts/utils/registerDynamicEndpoint";
app.use(express.json());
app.use("/chronicle", chronicleRouter);
app.use("/registry", registryRouter);
// ✅ Serve static files after all routers
app.use("/ops", opsRouter);
app.use("/insights", insightRouter);
app.use("/insights", insightPersistentRouter);
app.use("/cade", cadeRouter);
app.use("/autonomic", autonomicFeedbackRouter);
app.use("/reflective", reflectiveFeedbackRouter);
app.use("/schedule", schedulerRouter);
app.use("/cognitive", cognitiveRouter);
app.use("/system", systemHealthRouter);
app.use("/introspect", introspectiveRouter);
app.use("/adaptation", adaptationRouter);
app.use("/visual", insightVisualizerRouter);
app.use("/api/reflections", reflectionsRouter);
// ✅ Redirect /dashboard → /dashboard.html
app.get("/dashboard", (_req, res) => res.sendFile(path.join(publicDir, "dashboard.html")));
app.use((_req, res) => res.status(404).send("<h1>404 – Page not found</h1>"));
const PORT = process.env.PORT || 3001;
// ✅ Export app for imports
// ✅ Auto-mount all existing skills on startup
import fs from "fs";
(async () => {
  const skillDir = path.join(process.cwd(), "scripts", "skills");
  if (fs.existsSync(skillDir)) {
    for (const f of fs.readdirSync(skillDir)) {
      if (f.endsWith(".ts")) {
        const skill = f.replace(/\.ts$/, "");
        await registerDynamicEndpoint(app, skill);
      }
    }
  }
})();
// ✅ Only start server if this file is executed directly (not imported)
if (process.argv[1] && process.argv[1].includes("server.ts")) {
  app.listen(PORT, () => {
  // ✅ Serve public folder after all agent/registry routes
  // Delay dynamic route mounting until after server starts
  setTimeout(async () => {
    const skillDir = path.join(process.cwd(), "scripts", "skills");
    if (fs.existsSync(skillDir)) {
      for (const f of fs.readdirSync(skillDir)) {
        if (f.endsWith(".ts")) {
          const skill = f.replace(/\.ts$/, "");
          await registerDynamicEndpoint(app, skill);
        }
      }
      console.log("✅ All dynamic skill endpoints mounted.");
    }
  }, 800);
  }
// 🧩 Force delayed dynamic endpoint activation (guaranteed on live app)
        )
setTimeout(async () => {
  const { registerDynamicEndpoint } = await import("./scripts/utils/registerDynamicEndpoint.js");
  const fs = await import("fs");
  const path = await import("path");
    console.log("🧩 Post-listen re-mount complete: All skills live on current server instance.");
}, 1000);
  // <0001f9ea> Post-launch auto-registration (safe timing)
  (async () => {
    try {
      const { registerAllSkills } = await import("./scripts/utils/registerAllSkills.js");
      await registerAllSkills(app);
      console.log("<0001f9ea> ✅ All skill endpoints mounted after server launch.");
    } catch (err) {
      console.error("<0001f9ea> ⚠️ registerAllSkills failed:", err.message);
    }
  app.listen(PORT, () => {
    console.log(`🚀 Express server running at http://localhost:${PORT}`);
});

})();
}


(async () => {
  if (process.argv[1] && process.argv[1].includes("server.ts")) {
    const express = (await import("express")).default;
    const path = (await import("path")).default;
    const app = (await import("./server.ts")).default;
    app.use(express.static(path.resolve("public")));
    console.log("📦 Static middleware re-attached after all dynamic mounts.");
  }
})();

(async () => {
  if (process.argv[1] && process.argv[1].includes("server.ts")) {
    const express = (await import("express")).default;
    const path = (await import("path")).default;
    const { default: app } = await import("./server.ts");
    if (typeof app?.use === "function") {
      app.use(express.static(path.resolve("public")));
      console.log("📦 Static middleware re-attached after all dynamic mounts.");
    } else {
      console.warn("⚠️ Could not re-attach static middleware — app export not found.");
    }
  }
})();

(async () => {
  if (process.argv[1] && process.argv[1].includes("server.ts")) {
    const express = (await import("express")).default;
    const path = (await import("path")).default;
    const { getApp } = await import("./scripts/utils/appSingleton.js");
    const app = getApp();
    app.use(express.static(path.resolve("public")));
    console.log("📦 Static middleware re-attached after all dynamic mounts.");
  }
})();

// <0001f9f4> 🗂️ Serve static assets last (after all dynamic endpoints)
(async () => {
  if (process.argv[1] && process.argv[1].includes("server.ts")) {
    const express = (await import("express")).default;
    const path = (await import("path")).default;
    const { getApp } = await import("./scripts/utils/appSingleton");
    const app = getApp();
    if (typeof app?.use === "function") {
      app.use(express.static(path.resolve("public")));
      console.log("📦 Static middleware re-attached after all dynamic mounts.");
    } else {
      console.warn("⚠️ Static middleware skipped — invalid app reference.");
    }
  }
})();
