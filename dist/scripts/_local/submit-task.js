import fs from 'fs';
import path from 'path';
const [, , type = 'shell', command = 'echo Hello World', agent = 'cade'] = process.argv;
const taskId = `${agent}-manual-${Date.now()}`;
const task = {
    taskId,
    type,
    command,
    timeoutMs: 3000,
};
const QUEUE_PATH = path.resolve(`memory/queue/${taskId}.json`);
fs.writeFileSync(QUEUE_PATH, JSON.stringify(task, null, 2));
console.log(`📬 Submitted task for ${agent}:`, QUEUE_PATH);
