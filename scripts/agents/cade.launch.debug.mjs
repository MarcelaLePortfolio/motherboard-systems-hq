import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TASKS_DIR = path.resolve(__dirname, '../../memory/tasks');

console.log('DEBUG cwd:', process.cwd());
console.log('DEBUG TASKS_DIR exists?', fs.existsSync(TASKS_DIR));
console.log('DEBUG files in TASKS_DIR:', fs.readdirSync(TASKS_DIR, { withFileTypes: true })
                                      .filter(f => f.isFile())
                                      .map(f => f.name));

const taskFiles = fs.readdirSync(TASKS_DIR).filter(f => f.endsWith('.json'));

for (const taskFile of taskFiles) {
    const taskPath = path.join(TASKS_DIR, taskFile);
    const content = fs.readFileSync(taskPath, 'utf8');
    const task = JSON.parse(content);
    console.log('DEBUG task object:', task);

    if (task.payload?.action === 'runCommand') {
        try {
            console.log('Executing command:', task.payload.content);
            const output = execSync(task.payload.content, { encoding: 'utf8' });
            console.log('Command output:', output);
        } catch (err) {
            console.error('Error executing command:', err);
        }
    }
}
