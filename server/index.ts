/* KEEP ONLY UI ROUTE FIX (MINIMAL PATCHED ROLLBACK) */

import express from "express";
import path from "path";
import { pathToFileURL } from "url";
const app = express();

app.use(express.json());

app.get("/ui", (_req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Operator Cockpit</title>
  <link rel="stylesheet" href="/ui/styles.css" />
</head>
<body>

  <div class="topbar">
    <div class="project">
      Motherboard Systems HQ
    </div>

    <div class="health">
      ● Stable
    </div>
  </div>

  <div class="grid">

    <div class="panel workspace">
      <div class="panel-header">Workspace</div>
      <div class="panel-body">
        <div class="empty">System idle</div>
      </div>
    </div>

    <div class="panel telemetry">
      <div class="panel-header">Telemetry</div>
      <div class="panel-body">
        <div class="empty">No active streams</div>
      </div>
    </div>

  </div>

  <div class="atlas">
    System stable
  </div>

</body>
</html>
  `);
});

async function bootstrap() {
  const registryPath = pathToFileURL(
    path.resolve(process.cwd(), "server", "project-registry.mjs")
  ).href;
  const { mountProjectRegistryRoutes } = await import(registryPath);
  mountProjectRegistryRoutes(app);

  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
  });
}

bootstrap();

export default app;
