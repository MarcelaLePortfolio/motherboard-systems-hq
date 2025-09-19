import fs from 'fs';
import { execSync } from 'child_process';

setInterval(() => {
  const taskFiles = fs.readdirSync('memory/tasks').filter(f => f.endsWith('.json'));
  if (!taskFiles.length) return;

  taskFiles.forEach(file => {
    const filePath = `memory/tasks/${file}`;
    try {
      const task = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      const action = task.payload?.action;
      if (!action) {
        console.warn('⚠️ Task missing action field:', file);
        fs.unlinkSync(filePath);
        return;
      }

      console.log('📂 Found task file:', file);

      switch (action) {
        case 'runCommand':
          console.log('⚡ Executing command:', task.payload.content);
          console.log(execSync(task.payload.content, { encoding: 'utf8' }));
          break;
        case 'writeFile':
          fs.writeFileSync(task.payload.path, task.payload.content, 'utf8');
          console.log(`Cade wrote file: ${task.payload.path}`);
          break;
        case 'appendFile':
          fs.appendFileSync(task.payload.path, task.payload.content, 'utf8');
          console.log(`Cade appended file: ${task.payload.path}`);
          break;
        case 'deleteFile':
          fs.unlinkSync(task.payload.path);
          console.log(`Cade deleted file: ${task.payload.path}`);
          break;
        case 'moveFile':
          fs.renameSync(task.payload.from, task.payload.to);
          console.log(`Cade moved file from ${task.payload.from} to ${task.payload.to}`);
          break;
        case 'logMessage':
          console.log(`Cade log: ${task.payload.message}`);
          break;
        default:
          console.warn('⚠️ Unknown task type:', action);
      }

      fs.unlinkSync(filePath); // ✅ Remove task after execution
    } catch (e) {
      console.error('❌ Failed to parse task:', file, e);
      fs.unlinkSync(filePath);
    }
  });
}, 2000);
