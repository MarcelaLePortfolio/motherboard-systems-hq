import { startMatilda } from "@/agents/matilda";
import { setupMatildaContext } from "@/bootstrap/matilda-context";

(async () => {
  const context = await setupMatildaContext();
  await startMatilda(context);
})();
