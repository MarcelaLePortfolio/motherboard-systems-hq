// <0001fab8> Matilda Ollama Brain Bridge — fixed duplicate export

import { queryOllama } from "./matilda_brain.mts";

export const matilda = {
  async handler(message: string) {
    console.log("<0001fab8> [Matilda] Delegating to Ollama brain:", message);
    const reply = await queryOllama(message);
    return { message: reply };
  }
};

// ✅ Ensure only one export — no duplicate declarations.
