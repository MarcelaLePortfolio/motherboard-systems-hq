import { spawn } from "node:child_process";
export async function createBackupWithCade() {
  return new Promise((resolve) => {
    const backup = spawn("bash", ["scripts/_local/create_full_backup.sh"]);
    let output = "", error = "";

    backup.stdout.on("data", (data) => output += data.toString());
    backup.stderr.on("data", (data) => error += data.toString());

    backup.on("close", (code) => {
      if (code === 0) resolve({ status: "success", message: output.trim() });
      else resolve({ status: "error", message: error.trim() || "Backup failed" });
    });

    backup.on("error", (err) => resolve({ status: "error", message: err.message }));
  });
}
