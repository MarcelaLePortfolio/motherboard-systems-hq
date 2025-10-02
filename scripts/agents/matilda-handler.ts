import { cadeCommandRouter } from "./cade";  // use source import during dev

export async function matildaHandler(command: string, payload?: any, actor?: string) {
  try {
    const result = await cadeCommandRouter(command, payload);
    return {
      status: "success",
      cadeResult: result
    };
  } catch (err) {
    return {
      status: "error",
      cadeResult: { status: "error", message: String((err as any)?.message || err) }
    };
  }
}
