import path from "path";
import { pathToFileURL } from "url";
import { runShell } from "../utils/runShell";
const { runShell: execShell } = await import(pathToFileURL(path.resolve("scripts/utils/runShell.ts")).href); console.log("<0001FB1F> [Cade] dynamic import of runShell succeeded, type:", typeof execShell);

console.log("<0001f7e2> [Cade] execShell available:", typeof execShell);

const cadeCommandRouter = async (command: string, payload: any = {}) => {
  let result = "";

  try {
  console.log("<0001FB18> [Cade] cadeCommandRouter invoked with command:", command);
  console.log("<0001FB18> [Cade] typeof execShell at runtime:", typeof execShell);
console.log("<0001FB1E> [Cade] raw runShell reference:", runShell);
    switch (command) {
      case "dev:clean": {
        console.log("<0001FB20> [Cade] running dev:clean via execShell");
        try {
          const out = await execShell("scripts/dev-clean.sh");
          return { status: "success", result: out };
        } catch (err) {
          console.error("<0001FB20> [Cade] execShell threw:", err);
          return { status: "error", message: "[Cade execShell fail] " + (err?.message || String(err)) };
        }
      }