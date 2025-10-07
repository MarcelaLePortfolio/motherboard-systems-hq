// <0001fbA5> loadRouters – mount routers flat into app (no prefix rewrap)
import * as fs from "fs";
import * as path from "path";
import { pathToFileURL } from "url";
import { type Express } from "express";

export async function loadRouters(app: Express) {
  const apiDir = path.resolve("scripts/api");
  const files = fs.readdirSync(apiDir).filter(f => f.endsWith("-router.ts"));

  for (const file of files) {
    const moduleURL = pathToFileURL(path.join(apiDir, file)).href;
    const mod = await import(moduleURL);
    const router = mod.default;

    if (router && typeof router === "function") {
      app.use(router);
      console.log(`<0001fbA5> ✅ Mounted ${file} directly`);
    } else {
      console.warn(`⚠️ Skipped ${file}: invalid router export`);
    }
  }
}
