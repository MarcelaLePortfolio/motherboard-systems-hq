// <0001fb73> loadRouters – full introspection and guaranteed /api/<router> mount
import * as fs from "fs";
import * as path from "path";
import { pathToFileURL } from "url";
import type { Express } from "express";

export async function loadRouters(app: Express) {
  const apiDir = path.resolve("scripts/api");
  const files = fs.readdirSync(apiDir).filter(f => f.endsWith("-router.ts"));

  for (const file of files) {
    const routeName = file.replace("-router.ts", "");
    const routePath = `/api/${routeName}`;
    const moduleURL = pathToFileURL(path.join(apiDir, file)).href;
    const mod = await import(moduleURL);
    const router = mod.default || mod;

    if (router?.stack) {
      app.use(routePath, router);
      const routes =
        router.stack
          .filter((l: any) => l.route)
          .map(
            (l: any) =>
              Object.keys(l.route.methods)
                .map((m) => m.toUpperCase())
                .join(",") + " " + routePath + l.route.path
          );
      console.log(`<0001fb73> mounted ${file} →`, routes);
    } else {
      console.warn(`⚠️ Skipped ${file}: no valid router export`);
    }
  }
}
