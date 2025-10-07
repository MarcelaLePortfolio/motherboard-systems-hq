// <0001fb53> dynamic router autoloader (file:// safe for tsx runtime)
import * as fs from "fs";
import * as path from "path";
import { pathToFileURL } from "url";
import type { Express } from "express";

export async function loadRouters(app: Express) {
  const apiDir = path.resolve("scripts/api");
  const files = fs.readdirSync(apiDir).filter(f => f.endsWith("-router.ts"));
  const mounted = new Set<string>();

  for (const file of files) {
    const routeName = file.replace("-router.ts", "");
    const routePath = `/api/${routeName}`;

    if (mounted.has(routePath)) {
      console.warn(`⚠️ Skipping duplicate route: ${routePath}`);
      continue;
    }

    // ✅ Use file:// URL to ensure dynamic import works under tsx / ESM
    const moduleURL = pathToFileURL(path.join(apiDir, file)).href;
    const module = await import(moduleURL);
    const router = module.default;

    if (router) {
      app.use(routePath, router);
      mounted.add(routePath);
      console.log(`<0001fb53> mounted ${file} at ${routePath}`);
    } else {
      console.warn(`⚠️ Skipped ${file}: no default export`);
    }
  }
}
