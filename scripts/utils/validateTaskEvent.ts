import fs from "node:fs";
import { db } from "../../db/client";

export async function validateTaskEvent(eventId: string, payload: any, result: any) {
  console.log(`<0001f9fd> 🧩 Validating task event: ${eventId}`);
  try {
    let status = "success";

    // ✅ Simple heuristic: if result references a file, confirm it exists
    if (typeof result === "string" && result.includes("/")) {
      if (!fs.existsSync(result)) status = "error";
    }

    const stmt = db.prepare("UPDATE task_events SET status=@status WHERE id=@id");
    stmt.run({ id: eventId, status });

    console.log(`<0001f9fd> ✅ Validation complete — status: ${status}`);
    return status;
  } catch (err) {
    console.error("<0001f9fd> ❌ Validation failed:", err);
    return "error";
  }
}
