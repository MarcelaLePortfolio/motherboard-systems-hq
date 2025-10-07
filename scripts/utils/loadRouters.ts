// <0001fb6E> loadRouters – mounts correctly at /api/<name>
import * as fs from "fs";
import * as path from "path";
import { pathToFileURL } from "url";
import type { Express } from "express";

export async function loadRouters(app: Express) {
  const apiDir = path.resolve("scripts/api");
  const files = fs.readdirSync(apiDir).filter(f => f.endsWith("-router.ts"));

  for (const file of files) {
    const routeName = file.replace("-router.ts", "");
    const routePath = `/api/${routeName}`;  // ✅ correct absolute mount
    const moduleURL = pathToFileURL(path.join(apiDir, file)).href;
    const module = await import(moduleURL);
    const router = module.default;

    if (router) {
      app.use(routePath, router);
      console.log(`<0001fb6E> mounted ${file} at ${routePath}`);
    }
  }
}
