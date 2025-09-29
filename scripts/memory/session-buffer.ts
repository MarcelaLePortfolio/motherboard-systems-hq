type ChatMessage = { role: string; content: string };

const buffers: Record<string, ChatMessage[]> = {};

export function getBuffer(sid: string): ChatMessage[] {
  if (!buffers[sid]) buffers[sid] = [];
  return buffers[sid];
}

export function trimBuffer(buf: ChatMessage[]) {
  if (buf.length > 20) buf.splice(0, buf.length - 20);
}
