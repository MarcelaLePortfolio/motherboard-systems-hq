// <0001fb76> loadRouters – Express 5 verified base mount (no double prefix)
import * as fs from "fs";
import * as path from "path";
import { pathToFileURL } from "url";
import type { Express } from "express";

export async function loadRouters(app: Express) {
  const apiDir = path.resolve("scripts/api");
  const files = fs.readdirSync(apiDir).filter(f => f.endsWith("-router.ts"));

  for (const file of files) {
    const routeName = file.replace("-router.ts", "");
    const routePath = `/${routeName}`; // ✅ plain (no /api prefix)
    const moduleURL = pathToFileURL(path.join(apiDir, file)).href;
    const mod = await import(moduleURL);
    const router = mod.default || mod;

    if (router?.stack) {
      app.use(routePath, router);
      console.log(`<0001fb76> mounted ${file} at ${routePath}`);
    } else {
      console.warn(`⚠️ Skipped ${file}: invalid export`);
    }
  }
}
