const fs = require('fs');
const path = require('path');
const fetch = require('node-fetch');

const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');

function log(msg) {
  const logPath = path.join(__dirname, '../../../memory/cade_logbook.txt');
  fs.appendFileSync(logPath, `[${new Date().toISOString()}] ${msg}\n`);
}

function writeResume(result) {
  fs.writeFileSync(resumePath, JSON.stringify(result, null, 2));
}

function transformJSON(payload) {
  const inputPath = path.join(__dirname, '../../../', payload.input);
  const outputPath = path.join(__dirname, '../../../', payload.output);
  const data = JSON.parse(fs.readFileSync(inputPath, 'utf8'));

  if (payload.operation === 'transform_values') {
    const result = data.map(item => {
      const value = item[payload.key];
      if (typeof value !== 'string') return item;

      switch (payload.action) {
        case 'toLowerCase':
          item[payload.key] = value.toLowerCase();
          break;
        case 'toUpperCase':
          item[payload.key] = value.toUpperCase();
          break;
        case 'trim':
          item[payload.key] = value.trim();
          break;
        case 'addPrefix':
          item[payload.key] = `${payload.prefix || ''}${value}`;
          break;
        case 'addSuffix':
          item[payload.key] = `${value}${payload.suffix || ''}`;
          break;
      }

      return item;
    });

    fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));
    log(`✏️ Transformed values for key '${payload.key}' using '${payload.action}'`);
    return { result: `Transformed values written to ${payload.output}` };
  }

  throw new Error(`Unsupported transform operation: ${payload.operation}`);
}

function handleTask(task) {
  try {
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
