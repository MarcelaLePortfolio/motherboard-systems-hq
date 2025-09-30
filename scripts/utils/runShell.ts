import { exec } from "child_process";

  console.log("🚀 [runShell] preparing to execute:", cmd);
console.log("🚀 [runShell] preparing to execute:", cmd);
export async function runShell(cmd: string): Promise<string> {
  console.log("🚀 [runShell] preparing to execute:", cmd);
  return new Promise((resolve, reject) => {
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
      if (code === 0) resolve(output.trim());
      else reject(new Error(`Command "${cmd}" failed with code ${code}\n${output}`));
    });
  });
}
