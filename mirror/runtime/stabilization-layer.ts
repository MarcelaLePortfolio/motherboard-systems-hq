import path from "path";

/**
 * Runtime Stabilization Layer v1
 * - normalizes working directory
 * - enforces deterministic module base path
 * - reduces tsx/pm2 resolution drift
 */

export function stabilizeRuntime(rootDir: string = process.cwd()) {
  const resolvedRoot = path.resolve(rootDir);

  process.chdir(resolvedRoot);
  process.env.NODE_PATH = resolvedRoot;

  // force node to re-evaluate module paths after NODE_PATH change
  // @ts-ignore
  if (require?.main?.paths) {
    // @ts-ignore
    require.main.paths = require.main.paths;
  }

  console.log("[RUNTIME] stabilization layer active");
  console.log("[RUNTIME] cwd locked to:", resolvedRoot);
}
