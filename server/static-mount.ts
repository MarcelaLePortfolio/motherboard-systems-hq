
import express from "express";

import path from "path";

export function mountDashboard(app: express.Express) {

  const publicPath = path.join(process.cwd(), "public");

  app.use(express.static(publicPath));

  app.get("/", (_, res) => {

    res.sendFile(path.join(publicPath, "index.html"));

  });

}

