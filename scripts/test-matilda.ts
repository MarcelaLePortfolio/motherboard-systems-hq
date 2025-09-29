import { handleMatildaMessage } from "./agents/matilda-handler.js";

(async () => {
  try {
    const result = await handleMatildaMessage("test-session", "Hello Matilda, can you hear me?");
    console.log("Matilda replied:", result);
  } catch (err) {
    console.error("Matilda handler error:", err);
  }
})();
