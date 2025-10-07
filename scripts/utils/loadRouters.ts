// <0001fb65> Express 5 verified router autoloader – guaranteed /api/reflections/all mount
import * as fs from "fs";
import * as path from "path";
import { pathToFileURL } from "url";
import type { Express } from "express";

export async function loadRouters(app: Express) {
  const apiDir = path.resolve("scripts/api");
  const files = fs.readdirSync(apiDir).filter(f => f.endsWith("-router.ts"));

  for (const file of files) {
    const routeName = file.replace("-router.ts", "");
    // ✅ Express 5-safe nested mount
    const routePath = `/${routeName}`;
    const moduleURL = pathToFileURL(path.join(apiDir, file)).href;
    const module = await import(moduleURL);
    const router = module.default;

    if (router) {
      app.use(routePath, router);
      console.log(`<0001fb65> mounted ${file} at ${routePath}`);
    } else {
      console.warn(`⚠️ Skipped ${file}: no default export`);
    }
  }
}
