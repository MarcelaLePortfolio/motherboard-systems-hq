import fs from 'fs';

export async function handleDelete(task) {
  try {
    fs.unlinkSync(task.path);
    console.log("🗑️ [CADE] Deleted file:", task.path);
    return { status: "completed", result: "Deleted successfully." };
  } catch (err) {
    console.error("❌ Delete error:", err);
    return { status: "failed", result: err.message };
  }
}
