import fs from 'fs';

export async function handlePatch(task) {
  try {
    const { path, instructions } = task;
    console.log("<0001f9ea> Patch started. Task:", task);

    if (!fs.existsSync(path)) {
      throw new Error(`File does not exist: ${path}`);
    }

    const raw = fs.readFileSync(path, 'utf-8');
    console.log("📄 Original content:", raw);

    const fileContent = raw.split('\n');

    const match = instructions.match(/Replace line (\d+) with "(.*)"/);
    if (!match) {
      throw new Error('Unsupported patch instruction format');
    }

    const lineNumber = parseInt(match[1], 10) - 1;
    const newLine = match[2];

    console.log(`🔢 Line to replace: ${lineNumber}, New line: "${newLine}"`);

    if (lineNumber < 0 || lineNumber >= fileContent.length) {
      throw new Error('Invalid line number');
    }

    fileContent[lineNumber] = newLine;

    console.log("📝 Writing new content...");
    fs.writeFileSync(path, fileContent.join('\n'), 'utf-8');

    console.log("<0001fa79> ✅ [CADE] Patch complete:", path);
    return { status: "completed", result: `Line ${lineNumber + 1} replaced.` };
  } catch (err) {
    console.error("❌ Patch error:", err.stack);
    return { status: "failed", result: err.message };
  }
}
