import fs from "fs";
import path from "path";
import { sqlite } from "../../db/client.ts";
function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}
function logReflection(content) {
    try {
        const stmt = sqlite.prepare("INSERT INTO reflection_index (content) VALUES (?)");
        stmt.run(content);
    }
    catch (err) {
        console.error("<0001fb71> ❌ Failed to insert reflection:", err);
    }
}
function getNextDelegationTask() {
    const row = sqlite
        .prepare(`
      SELECT *
      FROM task_events
      WHERE status = 'pending'
        AND type = 'delegation'
      ORDER BY created_at ASC
      LIMIT 1
    `)
        .get();
    return row;
}
function updateTaskStatus(id, status, resultPayload) {
    const resultJson = typeof resultPayload === "undefined"
        ? null
        : JSON.stringify(resultPayload, null, 2);
    sqlite
        .prepare(`
      UPDATE task_events
      SET status = ?, result = ?
      WHERE id = ?
    `)
        .run(status, resultJson, id);
}
/**
 * Very simple instruction handler:
 * - Handles "create file X" or "create a webpage titled X"
 * - Creates the file in /public
 * - Wraps plain text into minimal HTML if needed
 */
async function handleInstruction(instruction) {
    const trimmed = instruction.trim();
    let summary = "No-op — instruction not recognized";
    // Try to detect a filename
    const fileMatch = trimmed.match(/file\s+([^\s"]+\.html?)/i) ||
        trimmed.match(/titled\s+([^\s"]+\.html?)/i);
    if (fileMatch) {
        const filename = fileMatch[1];
        const publicDir = path.join(process.cwd(), "public");
        const filePath = path.join(publicDir, filename);
        // Try to extract some quoted text
        const textMatch = trimmed.match(/text\s+["“](.+?)["”]/i) ||
            trimmed.match(/says\s+["“](.+?)["”]/i);
        const text = textMatch?.[1] ??
            "This file was created by Cade from a delegated instruction.";
        const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>${filename}</title>
</head>
<body style="background:#111; color:#eee; font-family: system-ui, sans-serif;">
  <h1>${text}</h1>
</body>
</html>
`;
        fs.writeFileSync(filePath, html, "utf8");
        console.log("<0001fb72> 📝 Cade wrote file:", filePath);
        summary = `Created file ${filename} with text: "${text}"`;
        return {
            summary,
            filename,
            filePath,
            instruction: trimmed,
        };
    }
    // If not a file instruction, just echo the instruction for now
    return {
        summary,
        instruction: trimmed,
    };
}
async function main() {
    console.log("<0001fb70> 🚀 Cade runner online — watching for delegated tasks (type='delegation')");
    logReflection("Cade runner online — watching for delegated tasks from Matilda…");
    while (true) {
        try {
            const task = getNextDelegationTask();
            if (!task) {
                // No pending tasks → short nap
                await sleep(1000);
                continue;
            }
            console.log(`<0001fb70> 🎯 Cade picked up task #${task.id} (${task.description})`);
            logReflection(`Cade picked up delegated task #${task.id} from ${task.agent || "Matilda"}`);
            // Mark as running
            updateTaskStatus(task.id, "running");
            // Parse payload
            let payload = {};
            try {
                payload = task.payload ? JSON.parse(task.payload) : {};
            }
            catch (err) {
                console.warn(`<0001fb71> ⚠️ Failed to parse payload for task #${task.id}:`, err);
            }
            const instruction = payload.instruction || task.description || "";
            if (!instruction.trim()) {
                console.warn(`<0001fb71> ⚠️ Task #${task.id} has no usable instruction`);
            }
            const result = await handleInstruction(instruction);
            updateTaskStatus(task.id, "completed", result);
            logReflection(`✅ Cade completed task #${task.id}: ${result.summary || "Done"}`);
        }
        catch (err) {
            console.error("<0001fb71> ❌ Cade loop error:", err);
            // Small backoff on error so we don’t spin
            await sleep(2000);
        }
    }
}
main().catch((err) => {
    console.error("<0001fb71> ❌ Cade runner fatal error:", err);
    process.exit(1);
});
