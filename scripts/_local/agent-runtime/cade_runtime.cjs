require('dotenv').config({ path: __dirname + '/../.env', override: true });
const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');
const fetch = require('node-fetch');

const MEMORY_DIR = path.join(__dirname, '../../memory');
const STATE_FILE = path.join(MEMORY_DIR, 'agent_chain_state.json');
const LOG_FILE = path.join(MEMORY_DIR, 'cade_runtime.log');
const IDLE_SLEEP_MS = 2000;
const HEARTBEAT_INTERVAL_MS = 120000;

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
const supabase = (SUPABASE_URL && SUPABASE_KEY) ? createClient(SUPABASE_URL, SUPABASE_KEY) : null;

function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}\n`;
  fs.appendFileSync(LOG_FILE, line);
  console.log(line.trim());
}

function loadTaskChain() {
  if (!fs.existsSync(STATE_FILE)) return null;
  try {
    return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
  } catch {
    return null;
  }
}

async function executeChain(chain) {
  log(`🛠️ Cade executing ${chain.length} task(s)`);
  const results = [];

  for (const task of chain) {
    try {
      if (task.type === 'fetch_url') {
        const res = await fetch(task.url);
        const data = await res.json();
        const outFile = path.join(MEMORY_DIR, task.output || 'fetched.json');
        fs.writeFileSync(outFile, JSON.stringify(data, null, 2));
        log(`🌐 Fetched URL → ${outFile}`);
        results.push({ status: 'success', task });

      } else if (task.type === 'write_db') {
        if (!supabase) throw new Error('Supabase not configured');
        const { table, row } = task;
        const { error } = await supabase.from(table).insert(row);
        if (error) throw error;
        log(`🗄️ Wrote to DB table "${table}": ${JSON.stringify(row)}`);
        results.push({ status: 'success', task });

      } else if (task.type === 'run_shell') {
        const { execSync } = require('child_process');
        const output = execSync(task.command, { encoding: 'utf8' });
        log(`💻 Shell executed: ${task.command}`);
        results.push({ status: 'success', output });

      } else {
        log(`⚠️ Unknown task type: ${task.type}`);
        results.push({ status: 'skipped', task });
      }

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

async function startLoop() {
  let lastHeartbeat = Date.now();
  while (true) {
    const chain = loadTaskChain();
    if (chain && Array.isArray(chain)) {
      await executeChain(chain);
    } else if (Date.now() - lastHeartbeat > HEARTBEAT_INTERVAL_MS) {
      log('💤 Cade idle and waiting for new chains...');
      lastHeartbeat = Date.now();
    }
    await new Promise(r => setTimeout(r, IDLE_SLEEP_MS));
  }
}

startLoop();
