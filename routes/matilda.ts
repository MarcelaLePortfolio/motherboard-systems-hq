
import { ollamaChat } from "../scripts/utils/ollamaChat.js";

export async function handler(message?: any) {

  const reply = await ollamaChat(String(message ?? ""));

  return reply;

}

