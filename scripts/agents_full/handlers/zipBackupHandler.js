import { execFile } from "child_process";
import fs from "fs";
import path from "path";
import { promisify } from "util";
const execFileAsync = promisify(execFile);

export default async function zipBackupHandler(options) {
    const targetDir = options?.dir || "memory";
    const absTargetDir = path.resolve(process.cwd(), targetDir);

    if (!fs.existsSync(absTargetDir)) throw new Error(`Target directory does not exist: ${absTargetDir}`);
    const parentDir = path.dirname(absTargetDir);
    const folderName = path.basename(absTargetDir);
    const outputFile = path.resolve(process.cwd(), options?.output || `${folderName}_backup.zip`);

    await execFileAsync("/usr/bin/zip", ["-r", outputFile, folderName], { cwd: parentDir });

    if (!fs.existsSync(outputFile)) throw new Error(`ZIP file was not created: ${outputFile}`);
    return { status: "zipped", outputFile };
}
