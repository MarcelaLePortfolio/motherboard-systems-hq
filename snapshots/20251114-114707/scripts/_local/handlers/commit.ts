import { execSync } from "child_process";

const message = process.argv[2] || "🤖 Auto-commit from Cade";
execSync("git add .", { stdio: "inherit" });
execSync(`git commit -m "${message}"`, { stdio: "inherit" });
execSync("git push", { stdio: "inherit" });
