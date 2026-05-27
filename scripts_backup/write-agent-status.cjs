 
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

try {
  const output = execSync("pm2 jlist", { encoding: "utf-8" });
  const agents = JSON.parse(output);

  const statusMap = {};

  ["matilda", "cade", "effie"].forEach((name) => {
    const proc = agents.find((p) => p.name === name);
    statusMap[name] = proc?.pm2_env?.status || "unknown";
  });

  const targetPath = path.join(__dirname, "../ui/dashboard/public/agent-status.json");
  fs.writeFileSync(targetPath, JSON.stringify(statusMap, null, 2));
  console.log("✅ Agent statuses written to", targetPath);
} catch (err) {
  console.error("❌ Failed to write agent status:", err);
  process.exit(1);
}
