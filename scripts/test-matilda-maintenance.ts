import { handleMatildaMessage } from "./agents/matilda-handler";

(async () => {
  const sid = "test-session";

  console.log("🔧 Test 1: reinstall/reset/rebuild");
  console.log(await handleMatildaMessage(sid, "please reinstall everything"));

  console.log("\n🔄 Test 2: restart/reload/fresh/boot");
  console.log(await handleMatildaMessage(sid, "restart the system"));
})();
