import fs from 'fs';
import path from 'path';

const chainPath = path.resolve('memory/agent_chain_state.json');

function readChainState(): any {
  try {
    const raw = fs.readFileSync(chainPath, 'utf8');
    return JSON.parse(raw);
  } catch (err) {
    console.error('❌ Matilda failed to read chain state:', err.message);
    return {};
  }
}

function writeAgentTask(agent: string, task: any) {
  const agentPath = path.resolve(`scripts/_local/memory/${agent}_task.json`);

  // Avoid overwrite if task already exists
  if (fs.existsSync(agentPath)) {
    console.log(`⚠️ Skipping: ${agent}_task.json already exists`);
    return;
  }

  fs.writeFileSync(agentPath, JSON.stringify(task, null, 2), 'utf8');
  console.log(`📤 Matilda wrote task for ${agent}`);
}

function processTasks() {
  const state = readChainState();
  const tasks = state?.tasks;

  if (!Array.isArray(tasks)) {
    console.log('ℹ️ No tasks to delegate yet');
    return;
  }

  for (const task of tasks) {
    if (!task?.agent || !task?.action) continue;

    writeAgentTask(task.agent, {
      type: task.action,
      payload: task.payload || null,
      from: 'matilda',
      taskId: task.id,
    });
  }
}

processTasks(); // Run immediately
setInterval(processTasks, 3000); // Then every 3s
console.log('⚡ Matilda Task Processor: Started');
