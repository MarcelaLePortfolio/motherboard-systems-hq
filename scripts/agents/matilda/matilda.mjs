import { ollamaChat } from "../../utils/ollamaChat.ts";
import { ollamaPlan } from "../../utils/ollamaPlan.ts";

export async function ask(input) {
  try {
    const planResponse = await ollamaPlan(input);
    if (planResponse && !planResponse.includes("No known skill")) return planResponse;
    const chatResponse = await ollamaChat(input);
    return chatResponse || "🤖 (no response)";
  } catch (err) {
    console.error("❌ Matilda ask() error:", err);
    return "🤖 (error during chat)";
  }
}

export const matilda = {
};
