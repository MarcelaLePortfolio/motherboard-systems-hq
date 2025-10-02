import { cadeCommandRouter } from "./cade";

export async function matildaHandler(command: string, payload?: any, actor?: string) {
  console.log("🔎 DEBUG: Matilda received command =", JSON.stringify(command), "payload =", JSON.stringify(payload));
  try {
    const result = await cadeCommandRouter(command, payload);
    return {
      status: "success",
      cadeResult: result
    };
  } catch (err: any) {
    return {
      status: "error",
      cadeResult: {
        status: "error",
        message: (err && typeof err === "object" && "message" in err)
          ? String((err as any).message)
          : String(err)
      }
    };
  }
}
