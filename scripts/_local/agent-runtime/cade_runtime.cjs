// 🧠 CADE – Backend Automator Logic (PHASE 1: Smart Task Types)

const fs = require('fs');
const path = require('path');

const logPath = path.join(__dirname, '../../../memory/chaining_runtime_log.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');
const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');

function log(message) {
  const entry = { timestamp: new Date().toISOString(), message };
  fs.appendFileSync(logPath, JSON.stringify(entry) + '\n');
}

function writeResume(data) {
  fs.writeFileSync(resumePath, JSON.stringify(data, null, 2));
}

function handleTask(task) {
  const type = task.type || 'unknown';
  const payload = task.payload || {};

  switch (type) {
    case 'echo':
      log(`🔁 Echo: ${payload.message || 'No message provided'}`);
      return { result: payload.message || 'No message provided' };

    case 'write_file':
      const writePath = path.join(__dirname, '../../../', payload.filename || 'cade_output.txt');
      fs.writeFileSync(writePath, payload.content || '');
      log(`📄 Wrote file: ${writePath}`);
      return { result: `Wrote file ${payload.filename}` };

    case 'append_log':
      const logLine = `[${new Date().toISOString()}] ${payload.content || 'No content'}`;
      const appendPath = path.join(__dirname, '../../../', payload.filename || 'cade_append_log.txt');
      fs.appendFileSync(appendPath, logLine + '\n');
      log(`📝 Appended to file: ${appendPath}`);
      return { result: `Appended to ${payload.filename}` };

    default:
      log(`❌ Unknown task type: ${type}`);
      return { error: `Unknown task type: ${type}` };
  }
}

function processTask() {
  if (!fs.existsSync(statePath)) {
    log('❌ No task file found for Cade.');
    return;
  }

  let task;
  try {
    task = JSON.parse(fs.readFileSync(statePath, 'utf8'));
  } catch (err) {
    log(`❌ Failed to parse task JSON: ${err.message}`);
    return;
  }

  log(`🛠️ Cade received task of type: ${task?.type || 'N/A'}`);

  try {
    const result = handleTask(task);
    writeResume(result);
  } catch (err) {
    log(`❌ Error during task handling: ${err.message}`);
    writeResume({ error: err.message });
  }
}

processTask();
