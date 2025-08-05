// ✅ CADE – Backend Automator Logic (Local Runtime)

const fs = require('fs');
const path = require('path');

function log(message) {
  const logPath = path.join(__dirname, '../../../memory/chaining_runtime_log.json');
  const logData = { timestamp: new Date().toISOString(), message };
  fs.appendFileSync(logPath, JSON.stringify(logData) + '\n');
}

function processTask() {
  const taskPath = path.join(__dirname, '../../../memory/agent_chain_state.json');
  if (!fs.existsSync(taskPath)) {
    log('❌ No task file found for Cade.');
    return;
  }

  let task;
  try {
    task = JSON.parse(fs.readFileSync(taskPath, 'utf8'));
  } catch (err) {
    log(`❌ Failed to parse task JSON: ${err.message}`);
    return;
  }

  log(`🛠️ Cade received task: ${task?.instruction || 'Unknown'}`);

  try {
    // Simulate processing the task
    const result = `✅ Cade completed task: "${task.instruction}"`;
    log(result);

    // Save output result
    const resultPath = path.join(__dirname, '../../../memory/resume_payload.json');
    fs.writeFileSync(resultPath, JSON.stringify({ result }, null, 2));
  } catch (err) {
    log(`❌ Error during task processing: ${err.message}`);
  }
}

processTask();
