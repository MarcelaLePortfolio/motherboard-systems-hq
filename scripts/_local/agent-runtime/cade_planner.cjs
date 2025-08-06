// 🤖 Cade Planner – Converts natural instructions into structured task chains
// <0053cade> Adds planning layer for self-sufficient Cade

const fs = require('fs');
const path = require('path');

const MEMORY_DIR = path.join(__dirname, '../../../memory');
const INBOX_FILE = path.join(MEMORY_DIR, 'cade_instructions.json');
const STATE_FILE = path.join(MEMORY_DIR, 'agent_chain_state.json');

function log(msg) {
  console.log(`[${new Date().toISOString()}] ${msg}`);
}

// ─── Load Instruction ───────────────────────────
function loadInstruction() {
  if (!fs.existsSync(INBOX_FILE)) return null;
  try {
    const data = JSON.parse(fs.readFileSync(INBOX_FILE, 'utf8'));
    if (!data || !data.instruction) return null;
    return data.instruction;
  } catch (err) {
    log(`❌ Failed to parse instructions: ${err.message}`);
    return null;
  }
}

// ─── Plan Tasks Based on Instruction ─────────────
// This is a simple template planner – can be expanded
function planTasks(instruction) {
  const tasks = [];

  const lower = instruction.toLowerCase();

  if (lower.includes('filter') && lower.includes('json')) {
    tasks.push({ type: 'read_file', file: 'sample.json' });
    tasks.push({ type: 'filter_json', key: 'status', value: 'active' });
    tasks.push({ type: 'write_file', file: 'output.json' });
  } else if (lower.includes('fetch')) {
    tasks.push({ type: 'fetch_url', url: 'https://jsonplaceholder.typicode.com/todos/1' });
    tasks.push({ type: 'write_file', file: 'fetched.json' });
  } else if (lower.includes('run') || lower.includes('shell')) {
    tasks.push({ type: 'run_shell', command: 'ls -la' });
  } else {
    tasks.push({ type: 'write_file', file: 'instruction_log.json', data: { note: instruction } });
  }

  return tasks;
}

// ─── Save Chain for Cade ────────────────────────
function saveChain(tasks) {
  fs.writeFileSync(STATE_FILE, JSON.stringify(tasks, null, 2), 'utf8');
  log(`✅ Planned ${tasks.length} task(s) and saved chain to ${STATE_FILE}`);
}

// ─── Main ──────────────────────────────────────
function main() {
  const instruction = loadInstruction();
  if (!instruction) {
    log('💤 No new instructions found.');
    return;
  }

  log(`🧠 Planning tasks for instruction: "${instruction}"`);

  const tasks = planTasks(instruction);
  saveChain(tasks);

  // Archive processed instruction
  const archivePath = path.join(MEMORY_DIR, `processed_instruction_${Date.now()}.json`);
  fs.renameSync(INBOX_FILE, archivePath);
  log(`🗂️ Instruction archived as ${archivePath}`);
}

main();
