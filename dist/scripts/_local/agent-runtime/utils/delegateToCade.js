// delegateToCade.js – Cade receives only the raw task description
import fs from 'fs';
import path from 'path';
export async function delegateToCade(taskDescription) {
    const taskFile = path.resolve('scripts/_local/agent-runtime/utils/cade_task.json');
    fs.writeFileSync(taskFile, JSON.stringify({
        task: taskDescription,
        timestamp: Date.now()
    }, null, 2));
    console.log(`Matilda → Cade: "${taskDescription}" delegated silently`);
}
