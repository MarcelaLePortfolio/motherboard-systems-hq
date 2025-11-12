import fs from 'fs';
import path from 'path';

const chainPath = path.resolve('memory/agent_chain_state.json');

function readChainState(): any {
  try {
    const raw = fs.readFileSync(chainPath, 'utf8');
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

function writeAgentTask(agent: string, task: any) {
  const agentPath = path.resolve(`scripts/_local/memory/${agent}_task.json`);
  fs.writeFileSync(agentPath, JSON.stringify(task, null, 2), 'utf8');
}

function processTasks() {
  const state = readChainState();
  const tasks = state?.tasks;

  if (!Array.isArray(tasks)) return;

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

setInterval(processTasks, 3000);
console.log('⚡ Matilda Task Processor: Started, polling every 3 seconds...');
