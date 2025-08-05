// --- Cade Runtime with Full Autonomy + Safety Mode Toggle ---
import fs from "fs";
import { exec } from "child_process";
import readline from "readline";
import path from "path";

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  prompt: "Cade> "
});

// Safety Mode toggle (default: OFF = full autonomy)
let safetyMode = false;

// Directories allowed if safety mode is on
const SAFE_DIRS = [
  "ui/dashboard",
  "server.js",
  "scripts/_local/agent-runtime"
];

function logEvent(msg) {
  const logPath = path.join(process.cwd(), "ui/dashboard/ticker-events.log");
  fs.appendFileSync(logPath, `⚡ Cade: ${msg}\n`);
  console.log(`⚡ Cade: ${msg}`);
}

// Executes a shell command with optional safety restrictions
function executeCommand(cmd) {
  if (safetyMode) {
    const lower = cmd.toLowerCase();
    const allowed = SAFE_DIRS.some(dir => lower.includes(dir.toLowerCase()));
    if (!allowed) {
      logEvent(`❎ Blocked (Safety Mode): ${cmd}`);
      return;
    }
  }

  logEvent(`Executing: ${cmd}`);
  exec(cmd, { cwd: process.cwd(), shell: "/bin/zsh" }, (error, stdout, stderr) => {
    if (error) {
      logEvent(`❌ Error: ${error.message}`);
      return;
    }
    if (stdout.trim()) logEvent(`📄 Output: ${stdout.trim().slice(0,500)}`);
    if (stderr.trim()) logEvent(`⚠️ Stderr: ${stderr.trim().slice(0,500)}`);
  });
}

function processInput(input) {
  const trimmed = input.trim();

  // Safety mode toggle
  if (trimmed === "safety:on") {
    safetyMode = true;
    logEvent("Safety Mode ENABLED. Only whitelisted paths allowed.");
    rl.prompt();
    return;
  }
  if (trimmed === "safety:off") {
    safetyMode = false;
    logEvent("Safety Mode DISABLED. Full autonomy granted.");
    rl.prompt();
    return;
  }

  // Default: treat as shell command
  if (trimmed) {
    executeCommand(trimmed);
  }

  rl.prompt();
}

console.log("⚡ Cade Runtime Started — Full Autonomy with Safety Toggle");
logEvent("cade agent-online");

rl.prompt();
rl.on("line", processInput);
