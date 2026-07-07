// <0001fb08> Phase 9.9i — Matilda Fully Decoupled Chat & Delegation
import { ollamaPlan } from "../../scripts/utils/ollamaPlan.js";
import { chatWithOllama } from "./utils/matilda_chat.js";

export const matilda = {
  name: "Matilda",
  async handler(message) {
    console.log(`<0001fb08> Matilda interpreting message: ${message}`);
    const lower = message.toLowerCase().trim();

    // 🪞 greet or short = direct chat only
    if (lower.length < 6 || ["hi", "hey", "yo", "hello", "sup"].includes(lower)) {
      return chatWithOllama(message);
    }

    // 🧭 Delegation intent check
    const delegationKeywords = /\b(delegate|cade|effie|task|run|create|generate|execute|validate)\b/;
    const isDelegation = delegationKeywords.test(lower);

    if (!isDelegation) {
      return chatWithOllama(message);
    }

    // 🤖 Delegation logic (separate brain)
    const plan = `Analyze and delegate this task appropriately: ${message}`;
    const response = await ollamaPlan(plan);
    return `🤖 Matilda delegated to Cade and reports: ${response}`;
  },
};
