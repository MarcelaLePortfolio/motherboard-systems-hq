// <0001fb7F> loadRouters – final fix (mount at /api/<name> explicitly)
import * as fs from "fs";
import * as path from "path";
import { pathToFileURL } from "url";
import type { Express } from "express";

export async function loadRouters(app: Express) {
  const apiDir = path.resolve("scripts/api");
  const files = fs.readdirSync(apiDir).filter(f => f.endsWith("-router.ts"));

  for (const file of files) {
    const routeName = file.replace("-router.ts", "");
    const routePath = `/${routeName}`; // ✅ Mount under its own folder name
    const moduleURL = pathToFileURL(path.join(apiDir, file)).href;
    const mod = await import(moduleURL);
    const router = mod.default || mod;

    if (router?.stack) {
      app.use(routePath, router);
      console.log(`<0001fb7F> mounted ${file} → /api${routePath}`);
    } else {
      console.warn(`⚠️ Skipped ${file}: invalid router export`);
    }
  }
}
