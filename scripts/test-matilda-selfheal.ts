import { handleMatildaMessage } from "./agents/matilda-handler";
import { getBuffer } from "./memory/session-buffer";

(async () => {
  let sid = "test-session";

  console.log("🔧 Test 1: simulate getReader bug");
  console.log(await handleMatildaMessage(sid, "simulate getReader error"));

  // 🔄 Reset buffer before next test
  getBuffer(sid).length = 0;

  console.log("\n🔧 Test 2: simulate JSON parse bug");
  console.log(await handleMatildaMessage(sid, "simulate JSON parse error"));
})();
