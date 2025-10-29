import { ollamaPlan } from "../utils/ollamaPlan.ts";
import { ollamaChat } from "../utils/ollamaChat.ts";

export const matilda = {
  name: "Matilda",
  role: "Delegation & Liaison",

  handler: async (message: string) => {
    try {
      // Try structured skill planning first
      const planResult = await ollamaPlan(message);
      if (planResult && !planResult.includes("No known skill")) {
        return planResult;
      }

      // Conversational fallback
      const chatResult = await ollamaChat(message);
      return chatResult || "🤖 (no response)";
    } catch (err) {
      console.error("❌ Matilda handler error:", err);
      return "🤖 (error during chat)";
    }
  },
};
