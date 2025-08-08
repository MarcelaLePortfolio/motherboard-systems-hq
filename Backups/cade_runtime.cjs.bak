const path = require('path'); // Import Node's path module for file path operations
const fs = require('fs');

function log(...args) {
  console.log(...args);
}

function writeResume(data) {
  const resumePath = path.join(__dirname, '../../../memory/agent_chain_resume.json');
  fs.writeFileSync(resumePath, JSON.stringify(data, null, 2), 'utf8');
  log(`✅ Wrote resume to ${resumePath}`);
}

function transformJSON(payload) {
  // stub function - implement as needed
  log('transformJSON called with payload:', payload);
  return { success: true };
}

function handleTask(task) {
  try {
    log('handleTask received:', task);
    switch (task.type) {
      case 'transform_json':
        return transformJSON(task.payload);
      default:
        return { error: `Unknown task type: ${task.type}` };
    }
  } catch (err) {
    return { error: err.message };
  }
}

function processTask() {
  log('Starting processTask');
  const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
  if (!fs.existsSync(statePath)) {
    log('❌ No task file found for Cade.');
    return;
  }

  let task;
  try {
    const rawData = fs.readFileSync(statePath, 'utf8');
    log(`Read task data: ${rawData}`);
    task = JSON.parse(rawData);
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
