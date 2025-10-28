import fs from "fs";
import { db } from "../../db/client.ts";

export async function validateTaskEvent(entryId: string, payload: any, result: string) {
  try {
    let isValid = true;

    if (payload?.filename) {
      isValid = fs.existsSync(`memory/${payload.filename}`);
    }

    const stmt = db.prepare("UPDATE task_events SET status=@status WHERE id=@id");
    stmt.run({ id: entryId, status: isValid ? "validated" : "error" });
    console.log(`<0001fab5> 🧩 Validation result for ${entryId}: ${isValid ? "✅ validated" : "❌ error"}`);
    return isValid;
  } catch (err) {
    console.error("<0001fab5> ❌ validateTaskEvent error:", err);
    return false;
  }
}
