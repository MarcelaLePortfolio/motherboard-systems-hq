import { readdirSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { resolve } from "node:path";

export async function runTestsWithCade() {
  const testDir = resolve("scripts/tests");
  const skip = ["watch_agent_state.sh"];
  const testFiles = readdirSync(testDir).filter(f => f.endsWith(".sh") && !skip.includes(f));

  const results = testFiles.map(file => {
    const fullPath = resolve(testDir, file);
    const result = spawnSync("bash", [fullPath], { encoding: "utf8", timeout: 10000 });
    return {
      file,
      success: result.status === 0,
      output: result.stdout?.trim() || result.stderr?.trim() || "No output"
    };
  });

  return { status: "success", results };
}
