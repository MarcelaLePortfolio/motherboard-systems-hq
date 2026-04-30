import { structuredLog } from "./structuredLogger.mjs";

// MANUAL RUNNER — safe, isolated
structuredLog("manual.run", {
  trigger: "on-demand",
  note: "observability check"
});
