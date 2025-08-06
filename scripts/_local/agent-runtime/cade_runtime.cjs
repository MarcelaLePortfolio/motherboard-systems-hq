// 🧠 Cade Runtime – Extended Task Handler with fetch_url + run_shell
// <0054cade> Cade can now execute shell commands & fetch URLs

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const { createClient } = require('@supabase/supabase-js');

const MEMORY_DIR = path.join(__dirname, '../../../memory');
const STATE_FILE = path.join(MEMORY_DIR, 'agent_chain_state.json');
const RESUME_FILE = path.join(MEMORY_DIR, 'agent_chain_resume.json');
const LOG_FILE = path.join(MEMORY_DIR, 'cade_runtime.log');

const IDLE_SLEEP_MS = 5000;
const HEARTBEAT_INTERVAL_MS = 120000;
let lastHeartbeat = Date.now();

// ─── Supabase ─────────────────────────────
require('dotenv').config({ path: path.join(__dirname, '../.env'), override: true });
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
const supabase = SUPABASE_URL && SUPABASE_KEY ? createClient(SUPABASE_URL, SUPABASE_KEY) : null;

function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}`;
  console.log(line);
  fs.appendFileSync(LOG_FILE, line + '\n');
}

function loadTaskChain() {
  if (!fs.existsSync(STATE_FILE)) return null;
  try { return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8')); }
  catch { return null; }
}

// ─── Handle Task ──────────────────────────
async function handleTask(task, inputData) {
  switch (task.type) {
    case 'read_file': {
      const filePath = path.join(MEMORY_DIR, task.file);
      return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    }
    case 'write_file': {
      const filePath = path.join(MEMORY_DIR, task.file);
      fs.writeFileSync(filePath, JSON.stringify(task.data || inputData, null, 2), 'utf8');
      return inputData;
    }
    case 'filter_json': {
      return inputData.filter(item => item[task.key] === task.value);
    }
    case 'sort_json': {
      return [...inputData].sort((a,b)=>a[task.key]>b[task.key]?1:-1);
    }
    case 'group_json': {
      return inputData.reduce((acc,item)=>{ const k=item[task.key]||'undefined'; (acc[k]=acc[k]||[]).push(item); return acc;},{});
    }
    case 'fetch_url': {
      const res = await fetch(task.url);
      return await res.json();
    }
    case 'run_shell': {
      const result = execSync(task.command, { encoding: 'utf8' });
      return { output: result };
    }
    default:
      throw new Error(`Unknown task type: ${task.type}`);
  }
}

// ─── Execute Chain ─────────────────────────
async function executeChain(chain) {
  let currentData = null;
  const results = [];

  for (const task of chain) {
    try {
      currentData = await handleTask(task, currentData);
      results.push({ status: 'success', type: task.type });
    } catch (err) {
      log(`❌ Task "${task.type}" failed: ${err.message}`);
      results.push({ status: 'failed', error: err.message });
    }
  }

  if (supabase) {
    await supabase.from('cade_task_history').insert([{ 
      status: 'success',
      summary: { steps: chain.map(t=>t.type) },
      full_chain: chain
    }]);
  }

  const timestamp = new Date().toISOString().replace(/[:.]/g,'-');
  const processedFile = path.join(MEMORY_DIR, `processed_chain_${timestamp}.json`);
  fs.renameSync(STATE_FILE, processedFile);
  log('✅ Task chain execution complete.');
}

// ─── Idle Loop ─────────────────────────────
async function startLoop() {
  while (true) {
    const chain = loadTaskChain();
    if (chain && Array.isArray(chain)) {
      log(`🛠️ Cade executing ${chain.length} task(s)`);
      await executeChain(chain);
    } else {
      if (Date.now() - lastHeartbeat > HEARTBEAT_INTERVAL_MS) {
        log('💤 Cade idle...');
        lastHeartbeat = Date.now();
      }
    }
    await new Promise(r=>setTimeout(r,IDLE_SLEEP_MS));
  }
}

startLoop();
