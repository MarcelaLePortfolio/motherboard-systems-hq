import * as fs from 'fs/promises';
import * as path from 'path';

const STATE_FILE = path.join(process.cwd(), 'memory', 'agent_chain_state.json');

async function runTask(task: any) {
  let type = task.type;
  if (type === 'task' && task.params?.path && task.params?.content) {
    type = 'generate_file';
  }

  if (type === 'generate_file') {
    const { path: filePath, content } = task.params;
    const abs = path.resolve(process.cwd(), filePath);
    if (!abs.startsWith(process.cwd())) throw new Error('Outside project root');
    await fs.writeFile(abs, content, 'utf8');
    console.log(`✅ Executed generate_file → ${filePath}`);
  } else {
    console.log(`❌ Unknown task type: ${task.type}`);
  }
}

async function watchState() {
  while (true) {
    try {
      const data = JSON.parse(await fs.readFile(STATE_FILE, 'utf8'));
      if (data.task) {
        await runTask(data.task);
        await fs.writeFile(STATE_FILE, '{}', 'utf8');
      }
    } catch {}
    await new Promise(res => setTimeout(res, 1000));
  }
}

console.log('Mirror stub: Launching Cade...');
watchState();
setInterval(() => console.log('💓 Cade heartbeat...'), 3000);
