// <0001fb62> deterministic API router loader – reflections mounts first
import * as fs from "fs";
import * as path from "path";
import { pathToFileURL } from "url";
import type { Express } from "express";

export async function loadRouters(app: Express) {
  const apiDir = path.resolve("scripts/api");
  let files = fs.readdirSync(apiDir).filter(f => f.endsWith("-router.ts"));

  // ✅ Always mount reflections first if present
  files = files.sort(f => (f.includes("reflections-router") ? -1 : 1));

  for (const file of files) {
    const routeName = file.replace("-router.ts", "");
    const routePath = `/api/${routeName}`;
    const moduleURL = pathToFileURL(path.join(apiDir, file)).href;
    const module = await import(moduleURL);
    const router = module.default;

    if (router) {
      app.use(routePath, router);
      console.log(`<0001fb62> mounted ${file} at ${routePath}`);
    } else {
      console.warn(`⚠️ Skipped ${file}: no default export`);
    }
  }
}
