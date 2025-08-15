import { execSync } from "child_process";

export function runShellCommand(cmd: string): string {
  try {
    const output = execSync(cmd, { stdio: "pipe" }).toString().trim();
    console.log(`💻 [CADE] Ran shell command: ${cmd}\n${output}`);
    return output;
  } catch (err: any) {
    console.error(`❌ [CADE] Shell command failed: ${cmd}`, err.message);
    return "";
  }
}
