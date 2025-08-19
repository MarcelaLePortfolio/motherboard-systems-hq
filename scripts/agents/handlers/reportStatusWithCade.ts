import { exec } from "node:child_process";
export async function reportStatusWithCade() {
  return new Promise((resolve) => {
    exec("pm2 jlist", (err, stdout, stderr) => {
      if (err) resolve({ status: "error", message: stderr || err.message });
      else {
        const list = JSON.parse(stdout);
        const agents = ["cade", "matilda", "effie"];
        const statuses = Object.fromEntries(
          agents.map(name => {
            const found = list.find((proc: any) => proc.name === name);
            return [name, found ? found.pm2_env.status : "offline"];
          })
        );
        resolve({ status: "success", agents: statuses });
      }
    });
  });
}
