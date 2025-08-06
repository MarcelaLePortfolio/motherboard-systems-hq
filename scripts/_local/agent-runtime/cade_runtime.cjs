// 🧠 Cade Runtime – Core Task Chain Execution (with idle-friendly loop)
// Last updated: <0045cade> Adds idle sleep to reduce log spam and CPU usage

const fs = require('fs');
const path = require('path');

const MEMORY_DIR = path.join(__dirname, '../../../memory');
const STATE_FILE = path.join(MEMORY_DIR, 'agent_chain_state.json');
const RESUME_FILE = path.join(MEMORY_DIR, 'agent_chain_resume.json');
const LOG_FILE = path.join(MEMORY_DIR, 'cade_runtime.log');

const IDLE_SLEEP_MS = 5000; // 5 seconds between idle checks

// Simple logger with timestamps
function log(message) {
  const line = `[${new Date().toISOString()}] ${message}`;
  console.log(line);
  fs.appendFileSync(LOG_FILE, line + '\n', 'utf8');
}

// Load current task chain state
function loadTaskChain() {
  if (!fs.existsSync(STATE_FILE)) return null;
  try {
    const rawData = fs.readFileSync(STATE_FILE, 'utf8');
    return JSON.parse(rawData);
  } catch (err) {
    log(`❌ Failed to parse task JSON: ${err.message}`);
    return null;
  }
}

// Save summary of executed chain
function saveResumeSummary(chain, results) {
  const summary = {
    timestamp: new Date().toISOString(),
    tasks: chain.map((task, i) => ({
      type: task.type,
      status: results[i].status,
      error: results[i].error || null,
      outputFile: results[i].outputFile || null
    }))
  };
  fs.writeFileSync(RESUME_FILE, JSON.stringify(summary, null, 2), 'utf8');
  log(`✅ Resume summary saved to ${RESUME_FILE}`);
}

// Core task handler
function handleTask(task, inputData) {
  const type = task.type;
  let data = inputData || null;
  let output = null;

  switch (type) {
    case 'read_file': {
      const filePath = path.join(MEMORY_DIR, task.file);
      output = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      log(`📄 Read file: ${task.file}`);
      break;
    }
    case 'write_file': {
      const filePath = path.join(MEMORY_DIR, task.file);
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
      output = data;
      log(`💾 Wrote file: ${task.file}`);
      break;
    }
    case 'sort_json': {
      if (!Array.isArray(data)) throw new Error('Data must be array for sort_json');
      const key = task.key;
      output = [...data].sort((a, b) => (a[key] > b[key] ? 1 : -1));
      log(`🔀 Sorted JSON by key: ${key}`);
      break;
    }
    case 'filter_json': {
      if (!Array.isArray(data)) throw new Error('Data must be array for filter_json');
      const key = task.key;
      const value = task.value;
      output = data.filter(item => item[key] === value);
      log(`🔎 Filtered JSON where ${key}=${value}`);
      break;
    }
    case 'transform_json': {
      if (!Array.isArray(data)) throw new Error('Data must be array for transform_json');
      const key = task.key;
      const action = task.action || 'uppercase';
      output = data.map(item => {
        const newItem = { ...item };
        if (newItem[key]) {
          if (action === 'uppercase') newItem[key] = String(newItem[key]).toUpperCase();
          else if (action === 'lowercase') newItem[key] = String(newItem[key]).toLowerCase();
        }
        return newItem;
      });
      log(`✨ Transformed JSON key: ${key} with action: ${action}`);
      break;
    }
    case 'group_json': {
      if (!Array.isArray(data)) throw new Error('Data must be array for group_json');
      const key = task.key;
      output = data.reduce((acc, item) => {
        const k = item[key] || 'undefined';
        acc[k] = acc[k] || [];
        acc[k].push(item);
        return acc;
      }, {});
      log(`📊 Grouped JSON by key: ${key}`);
      break;
    }
    default:
      throw new Error(`Unknown task type: ${type}`);
  }

  return output;
}

// Execute chain
function executeChain(chain) {
  let currentData = null;
  const results = [];

  for (const task of chain) {
    try {
      currentData = handleTask(task, currentData);
      results.push({ status: 'success', outputFile: task.type === 'write_file' ? task.file : null });
    } catch (err) {
      log(`❌ Error processing task "${task.type}": ${err.message}`);
      results.push({ status: 'failed', error: err.message });
    }
  }

  saveResumeSummary(chain, results);
  log('✅ Task chain execution complete.');

  // Auto-rename processed chain
  try {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const processedFile = path.join(MEMORY_DIR, `processed_chain_${timestamp}.json`);
    fs.renameSync(STATE_FILE, processedFile);
    log(`🗂️ Task chain file renamed to ${processedFile}`);
  } catch (err) {
    log(`⚠️ Failed to rename chain file: ${err.message}`);
  }
}

// Idle-friendly loop
async function startLoop() {
  while (true) {
    const chain = loadTaskChain();
    if (chain && Array.isArray(chain)) {
      log(`🛠️ Cade starting chain of ${chain.length} task(s)`);
      executeChain(chain);
    }
    await new Promise(resolve => setTimeout(resolve, IDLE_SLEEP_MS));
  }
}

startLoop();
