import { log } from '../utils/logger';
import * as path from 'path';
import * as fs from 'fs';

function processTask() {
  const statePath = path.resolve('memory/agent_chain_state.json');
  log(`📍 Resolved task file path: ${statePath}`);

  if (!fs.existsSync(statePath)) {
    log('❌ No task file found for Matilda.');
    return;
  }

  let task;
  try {
    const rawData = fs.readFileSync(statePath, 'utf8');
    log(`📄 Raw file contents: ${rawData}`);
    log(`🧪 Raw length: ${rawData.length}`);
    task = JSON.parse(rawData);
    log(`✅ JSON parsed: ${JSON.stringify(task)}`);
log(`🧬 Type of task.agent: ${typeof task.agent} | Value: ${task.agent}`);
  } catch (err) {
    log(`❌ Failed to parse task JSON: ${err}`);
    return;
  }

  if (!task || typeof task !== 'object') {
    log(`⚠️ Invalid or empty task object.`);
    return;
  }

  if (!task.agent) {
    log(`⚠️ No agent specified in task, assuming Matilda...`);
    task.agent = 'Matilda';
  }

  if (task.agent !== 'Matilda') {
    log(`📭 Task assigned to another agent: ${task.agent}`);
    return;
  }

  log(`✅ Matilda is processing: ${JSON.stringify(task, null, 2)}`);
}

log('💚 Matilda runtime started.');
setInterval(() => {
  log('🤖 Matilda task processor active...');
  processTask();
}, 3000);
