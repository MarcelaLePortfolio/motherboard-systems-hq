#!/usr/bin/env node

// 🔹 Matilda Auto Deploy Patch Script with Heartbeat Logging
const fs = require('fs');
const path = require('path');

const PROJECT_DIR = process.env.HOME + "/Desktop/Motherboard_Systems_HQ";
const UI_SRC = path.join(PROJECT_DIR, "ui/dashboard");
const SERVE_ROOT = path.join(UI_SRC, "serve-root");
const LOG_FILE = path.join(UI_SRC, "public/matilda-log.json");
const CHECKSUM_FILE = path.join(PROJECT_DIR, "memory/last_ui_checksum.txt");

function getChecksum(dir) {
  const crypto = require('crypto');
  const hash = crypto.createHash('sha256');

  function walkSync(currentDirPath) {
    fs.readdirSync(currentDirPath).forEach(function (name) {
      const filePath = path.join(currentDirPath, name);
      const stat = fs.statSync(filePath);
      if (stat.isFile()) {
        hash.update(fs.readFileSync(filePath));
      } else if (stat.isDirectory()) {
        walkSync(filePath);
      }
    });
  }

  walkSync(UI_SRC);
  return hash.digest('hex');
}

function appendLog(message) {
  const timestamp = new Date().toISOString();
  let logs = [];
  try {
    logs = JSON.parse(fs.readFileSync(LOG_FILE, 'utf8'));
  } catch (e) {
    logs = [];
  }
  logs.push(`[${timestamp}] ${message}`);
  fs.writeFileSync(LOG_FILE, JSON.stringify(logs.slice(-200), null, 2)); // keep last 200 entries
}

(async () => {
  const newChecksum = getChecksum(UI_SRC);
  const oldChecksum = fs.existsSync(CHECKSUM_FILE) ? fs.readFileSync(CHECKSUM_FILE, 'utf8').trim() : '';

  if (newChecksum !== oldChecksum) {
    appendLog("⚡ UI change detected — triggering deploy...");
    console.log("Deploying updated UI...");

    // run deploy-ui.sh
    require('child_process').execSync(`${PROJECT_DIR}/tools/deploy-ui.sh`, { stdio: 'inherit' });

    fs.writeFileSync(CHECKSUM_FILE, newChecksum);
    appendLog("✅ Auto-deploy complete!");
  } else {
    // Heartbeat log if no changes
    appendLog("🔹 Auto-deploy check complete — no UI changes detected");
  }
})();
