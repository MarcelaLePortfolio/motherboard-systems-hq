import { ollamaChat } from "../scripts/utils/ollamaChat.js";

export async function handler(message?: any) {
  const result = await ollamaChat(
    String(message ?? ""),
  );

  return result.reply;
}
