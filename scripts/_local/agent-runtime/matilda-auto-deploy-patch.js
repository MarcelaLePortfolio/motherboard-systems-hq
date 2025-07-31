#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execSync } = require('child_process');

const PROJECT_DIR = process.env.HOME + '/Desktop/Motherboard_Systems_HQ';
const UI_SRC = path.join(PROJECT_DIR, 'ui/dashboard');
const CHECKSUM_FILE = path.join(PROJECT_DIR, 'ui/dashboard/.last_checksum');
const LOG_FILE = path.join(PROJECT_DIR, 'Backups/Logs/matilda_auto_deploy.json');

function getChecksum(dir) {
  const hash = crypto.createHash('md5');
  function walkSync(currentPath) {
    fs.readdirSync(currentPath).forEach(file => {
      const fullPath = path.join(currentPath, file);
      const stat = fs.statSync(fullPath);
      if (stat.isDirectory()) {
        walkSync(fullPath);
      } else {
        hash.update(fs.readFileSync(fullPath));
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
  fs.writeFileSync(LOG_FILE, JSON.stringify(logs.slice(-200), null, 2));
}

(async () => {
  const newChecksum = getChecksum(UI_SRC);
  const oldChecksum = fs.existsSync(CHECKSUM_FILE) ? fs.readFileSync(CHECKSUM_FILE, 'utf8').trim() : '';

  if (newChecksum !== oldChecksum) {
    appendLog("⚡ UI change detected — triggering deploy...");
    console.log("Deploying updated UI...");

    // run deploy-ui.sh
    execSync(`${PROJECT_DIR}/tools/deploy-ui.sh`, { stdio: 'inherit' });

    fs.writeFileSync(CHECKSUM_FILE, newChecksum);
    appendLog("✅ Auto-deploy complete!");
    execSync(`node "${PROJECT_DIR}/tools/log-to-ticker.js" "✅ Auto-deploy complete!"`);
  } else {
    // Heartbeat log if no changes
    appendLog("🔹 Auto-deploy check complete — no UI changes detected");
    execSync(`node "${PROJECT_DIR}/tools/log-to-ticker.js" "🔹 Auto-deploy heartbeat"`);
  }
})();
