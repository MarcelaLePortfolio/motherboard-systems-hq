import { exec } from "child_process";

export async function runShell(cmd: string): Promise<string> {
  console.log("🚀 [runShell] preparing to execute:", cmd);
  console.trace("<0001FB12> [runShell] call stack trace");
  return new Promise((resolve, reject) => {
    try {
      const child = exec(cmd, { cwd: process.cwd(), env: process.env });
      let output = "";
      child.stdout?.on("data", (data) => {
        process.stdout.write(data);
        output += data;
      });
      child.stderr?.on("data", (data) => {
        process.stderr.write(data);
        output += data;
      });
      child.on("close", (code) => {
        if (code === 0) {
          console.log("✅ [runShell] finished successfully:", cmd);
          resolve(output.trim());
        } else {
          console.error("❌ [runShell] non-zero exit code:", code, "for", cmd);
          reject(new Error(`Command "${cmd}" failed with code ${code}\n${output}`));
        }
      });
    } catch (err: any) {
      console.error("💥 [runShell] unexpected failure:", err);
      reject(err);
    }
  });
}

console.log("<0001FB11> [runShell] module loaded, export type:", typeof runShell);
