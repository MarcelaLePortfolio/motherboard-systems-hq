/* KEEP ONLY UI ROUTE FIX (MINIMAL PATCHED ROLLBACK) */

import express from "express";
import path from "path";
import { pathToFileURL } from "url";

import apiChatRouter from "../routes/api-chat";
import packageReadRouter from "../routes/api-package-read";
import missionReadRouter from "../routes/api-mission-read";
import { initializeCanonicalPackageSchema } from "../db/matilda-canonical-package-runtime";
import matildaCanonicalPackageRouter from "./routes/matilda-canonical-package-route";

const app = express();

app.locals.canonicalPackageSchemaReady = false;

app.use(express.json());
app.use(apiChatRouter);
app.use(missionReadRouter);
app.use(packageReadRouter);
app.use(matildaCanonicalPackageRouter);

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
  try {
    initializeCanonicalPackageSchema();
    app.locals.canonicalPackageSchemaReady = true;
  } catch (err) {
    app.locals.canonicalPackageSchemaReady = false;
    console.error(
      "[bootstrap] Canonical Package schema initialization failed; " +
        "POST /api/matilda/canonical-package will reject requests until this is resolved:",
      err,
    );
  }

  const registryPath = pathToFileURL(
    path.resolve(process.cwd(), "server", "project-registry.mjs"),
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
