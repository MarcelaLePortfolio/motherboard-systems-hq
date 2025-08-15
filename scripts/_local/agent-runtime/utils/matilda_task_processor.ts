import fs from 'fs';
import path from 'path';

const TASK_FILE = path.join(__dirname, '../../memory/agent_chain_state.json');

export async function startMatildaTaskProcessor() {
  console.log('🤖 Matilda task processor active...');

  setInterval(() => {
    console.log('🔍 Checking for task file...');
    if (!fs.existsSync(TASK_FILE)) {
      console.log('🕳️ No file found.');
      return;
    }

    try {
      const raw = fs.readFileSync(TASK_FILE, 'utf-8');
      console.log('📄 Raw file contents:', raw);
      console.log('🧪 Raw length:', raw.length);

      const task = JSON.parse(raw);
      console.log('✅ JSON parsed:', task);

      if (task?.agent !== 'Matilda') {
        console.log(`📭 Task assigned to another agent: ${task?.agent}`);
        return;
      }

      console.log(`📩 Received task for Matilda:`, task);
      routeMatildaTask(task);
    } catch (err) {
      console.error('❌ Error parsing or routing task:', err.message);
    }
  }, 3000);
}

function routeMatildaTask(task: any) {
  console.log('🔀 Matilda (echoing):', task);
}
