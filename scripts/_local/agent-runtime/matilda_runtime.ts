import { logEvent, setStatus } from './shared_utils.js';

logEvent('matilda', '💚 Matilda online');
setStatus('matilda', 'online');

setInterval(() => {
  setStatus('matilda', 'online');
}, 5000);


function delegateTaskToAgent(task, targetAgent = 'cade') {
  const fs = require('fs');
  const path = require('path');
  const { v4: uuidv4 } = require('uuid');

  const taskId = task.taskId || `\${targetAgent}-delegated-\${uuidv4()}`;
  const taskFilePath = path.resolve(`memory/queue/\${taskId}.json`);

  const delegatedTask = {
    taskId,
    ...task,
    delegatedBy: 'matilda',
    timestamp: Date.now(),
  };

  try {
    fs.writeFileSync(taskFilePath, JSON.stringify(delegatedTask, null, 2));
    console.log(`📤 Matilda delegated task to \${targetAgent}:`, taskFilePath);
  } catch (err) {
    console.error(`❌ Failed to delegate task to \${targetAgent}:`, err.message);
  }
}
console.log("🤖 Matilda Runtime Started — Ready for tasks!");

function pollQueue() {
  const fs = require('fs');
  const path = require('path');

  setInterval(() => {
    const queueDir = path.resolve('memory/queue');
    const files = fs.readdirSync(queueDir).filter(f => f.endsWith('.json'));
    for (const file of files) {
      const filePath = path.join(queueDir, file);
      try {
        const task = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        console.log("📦 Task received:", task);

        if (task.type === "shell") {
          const { exec } = require('child_process');
          exec(task.command, (error, stdout, stderr) => {
            if (error) {
              console.error("❌ Shell error:", error.message);
            } else {
              console.log("✅ Shell output:", stdout.trim());
            }
            fs.unlinkSync(filePath);
          });
        } else if (task.type === "delegate") {
          delegateTaskToAgent(task.payload, task.targetAgent);
          fs.unlinkSync(filePath);
        }

      } catch (err) {
        console.error("❌ Failed to process task:", filePath, err.message);
      }
    }
  }, 3000);
}

pollQueue();
