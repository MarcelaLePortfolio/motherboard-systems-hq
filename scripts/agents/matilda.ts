import { log } from '../../utils/logger';
import { readFileSync, existsSync } from 'fs';
import path from 'path';

const taskFilePath = path.resolve('memory/agent_chain_state.json');

function processTask() {
  log('🔍 Checking for task file...');
  if (!existsSync(taskFilePath)) {
    log('❌ No task file found.');
    return;
  }

  const rawData = readFileSync(taskFilePath, 'utf8');
  log(`📄 Raw task string: ${rawData}`);

  let task: any;
  try {
    task = JSON.parse(rawData);
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
  // ... implement Matilda’s task logic here
}

log('💚 Matilda runtime started.');
setInterval(() => {
  log('🤖 Matilda task processor active...');
  processTask();
}, 3000);
