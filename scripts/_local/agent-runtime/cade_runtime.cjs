// 🧠 Cade Runtime – Quick Heartbeat Test Mode
// Temporarily reduces heartbeat to 10 seconds for verification

const fs = require('fs');
const path = require('path');

const MEMORY_DIR = path.join(__dirname, '../../../memory');
const STATE_FILE = path.join(MEMORY_DIR, 'agent_chain_state.json');
const RESUME_FILE = path.join(MEMORY_DIR, 'agent_chain_resume.json');
const LOG_FILE = path.join(MEMORY_DIR, 'cade_runtime.log');

const IDLE_SLEEP_MS = 5000;        // check every 5 seconds
const HEARTBEAT_INTERVAL_MS = 10000; // 10-second heartbeat for test

let lastHeartbeat = Date.now();

function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}`;
  console.log(line);
  fs.appendFileSync(LOG_FILE, line + '\n');
}

function loadTaskChain() {
  if (!fs.existsSync(STATE_FILE)) return null;
  try { return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8')); }
  catch (err) { log(`❌ Failed to parse task JSON: ${err.message}`); return null; }
}

function executeChain(chain) {
  let currentData = null;
  for (const task of chain) {
    try {
      if (task.type === 'read_file') {
        currentData = JSON.parse(fs.readFileSync(path.join(MEMORY_DIR, task.file), 'utf8'));
        log(`📄 Read file: ${task.file}`);
      } else if (task.type === 'filter_json') {
        currentData = currentData.filter(i => i[task.key] === task.value);
        log(`🔎 Filtered JSON where ${task.key}=${task.value}`);
      } else if (task.type === 'sort_json') {
        currentData = [...currentData].sort((a, b) => (a[task.key] > b[task.key] ? 1 : -1));
        log(`🔀 Sorted JSON by key: ${task.key}`);
      } else if (task.type === 'write_file') {
        fs.writeFileSync(path.join(MEMORY_DIR, task.file), JSON.stringify(currentData, null, 2));
        log(`💾 Wrote file: ${task.file}`);
      }
    } catch (err) { log(`❌ Error processing task "${task.type}": ${err.message}`); }
  }

  const processedFile = path.join(MEMORY_DIR, `processed_chain_${Date.now()}.json`);
  fs.renameSync(STATE_FILE, processedFile);
  log(`🗂️ Task chain file renamed to ${processedFile}`);
}

async function startLoop() {
  while (true) {
    const chain = loadTaskChain();
    if (chain) { log(`🛠️ Cade starting chain of ${chain.length} task(s)`); executeChain(chain); }
    else {
      const now = Date.now();
      if (now - lastHeartbeat >= HEARTBEAT_INTERVAL_MS) {
        log('💤 Cade idle and waiting for new chains...');
        lastHeartbeat = now;
      }
    }
    await new Promise(r => setTimeout(r, IDLE_SLEEP_MS));
  }
}

startLoop();
