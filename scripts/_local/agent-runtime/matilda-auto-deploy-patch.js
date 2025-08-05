#!/usr/bin/env node
// =========================================
// Matilda Auto-Deploy Patch Script
// =========================================

const { execSync } = require("child_process");
const fs = require("fs");

console.log("🔄 Checking for UI changes...");
try {
  execSync("git pull && git status", { stdio: "inherit" });
  // Simulate deploy trigger (replace with real logic if needed)
  console.log("🚀 Auto-deploy triggered...");

  // ✅ Event emitter for dashboard ticker
  fs.appendFileSync(
    "ui/dashboard/ticker-events.log",
    `{"timestamp":"${Math.floor(Date.now()/1000)}","agent":"matilda","event":"auto-deploy"}\n`
  );
} catch (err) {
  console.error("❌ Auto-deploy failed:", err);
  process.exit(1);
}
