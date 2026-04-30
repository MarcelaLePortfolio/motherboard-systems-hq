import { structuredLog } from "./structuredLogger.mjs";

// SAFE TEST — no execution path impact
structuredLog("test.event", {
  status: "ok",
  source: "manual-test"
});
