import { readdir } from "fs/promises";
import { exec } from "child_process";
import { promisify } from "util";
const execAsync = promisify(exec);

export default async function reportStatusHandler(options) {
    const target = options?.target;
    if (target === "agents") {
        const { stdout } = await execAsync("pm2 ls", { cwd: process.cwd() });
        return { status: "agents listed", output: stdout.trim() };
    } else if (target === "files") {
        const dir = options?.dir || "memory";
        const files = await readdir(dir);
        return { status: "files listed", files };
    }
    return { error: "Invalid target specified" };
}
