// 🧠 Cade Runtime – Core Task Chain Execution with Supabase Integration (Env-Based)
// Last updated: <0051cade> Uses environment variables for Supabase keys for security

const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');

// ─── Configuration ──────────────────────────────
const MEMORY_DIR = path.join(__dirname, '../../../memory');
const STATE_FILE = path.join(MEMORY_DIR, 'agent_chain_state.json');
const RESUME_FILE = path.join(MEMORY_DIR, 'agent_chain_resume.json');
const LOG_FILE = path.join(MEMORY_DIR, 'cade_runtime.log');

const IDLE_SLEEP_MS = 5000;           // check every 5 seconds
const HEARTBEAT_INTERVAL_MS = 120000; // 2-minute heartbeat

let lastHeartbeat = Date.now();

// ─── Supabase Client (from env) ─────────────────
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error("❌ Missing Supabase env vars: SUPABASE_URL and/or SUPABASE_KEY");
  process.exit(1);
}
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

// ─── Utility: Logging ───────────────────────────
function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}`;
  console.log(line);
  fs.appendFileSync(LOG_FILE, line + '\n');
}

// ─── Load Current Chain ─────────────────────────
function loadTaskChain() {
  if (!fs.existsSync(STATE_FILE)) return null;
  try { return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8')); }
  catch (err) { log(`❌ Failed to parse task JSON: ${err.message}`); return null; }
}

// ─── Save Local Resume Summary ──────────────────
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
  return summary;
}

// ─── Push Chain to Supabase ─────────────────────
async function pushChainToSupabase(chain, results, status, outputFile) {
  const summary = {
    steps: chain.map(t => t.type),
    status,
    outputFile,
    errors: results.filter(r => r.status === 'failed').map(r => r.error)
  };

  const { data, error } = await supabase
    .from('cade_task_history')
    .insert([
      {
        status,
        output_file: outputFile || null,
        summary,
        full_chain: chain
      }
    ]);

  if (error) log(`⚠️ Supabase insert error: ${error.message}`);
  else log(`☁️ Chain pushed to Supabase successfully`);
}

// ─── Core Task Handler ──────────────────────────
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

// ─── Execute Chain ─────────────────────────────
async function executeChain(chain) {
  let currentData = null;
  const results = [];
  let lastOutputFile = null;

  for (const task of chain) {
    try {
      currentData = handleTask(task, currentData);
      const outputFile = task.type === 'write_file' ? task.file : null;
      if (outputFile) lastOutputFile = outputFile;
      results.push({ status: 'success', outputFile });
    } catch (err) {
      log(`❌ Error processing task "${task.type}": ${err.message}`);
      results.push({ status: 'failed', error: err.message });
    }
  }

  const summary = saveResumeSummary(chain, results);
  await pushChainToSupabase(chain, results, 'success', lastOutputFile);

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

// ─── Idle Loop with Heartbeat ──────────────────
async function startLoop() {
  while (true) {
    const chain = loadTaskChain();
    if (chain && Array.isArray(chain)) {
      log(`🛠️ Cade starting chain of ${chain.length} task(s)`);
      await executeChain(chain);
    } else {
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
