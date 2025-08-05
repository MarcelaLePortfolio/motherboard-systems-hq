const fs = require('fs');
const path = require('path');

const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');

function log(msg) {
  console.log(msg);
  fs.appendFileSync('cade.log', `[${new Date().toISOString()}] ${msg}\n`);
}

function writeResume(result) {
  fs.writeFileSync(resumePath, JSON.stringify(result, null, 2));
}

function transformJSON(payload) {
  const fullInputPath = path.join(__dirname, '../../../', payload.input);
  const raw = fs.readFileSync(fullInputPath, 'utf8');
  const data = JSON.parse(raw);

  switch (payload.operation) {
    case 'transform_values': {
      const transformFn = getTransformFunction(payload.transform);
      const transformed = data.map(entry => {
        if (entry[payload.key] != null) {
          entry[payload.key] = transformFn(entry[payload.key]);
        }
        return entry;
      });
      const outPath = path.join(__dirname, '../../../', payload.output);
      fs.writeFileSync(outPath, JSON.stringify(transformed, null, 2));
      log(`🔤 Transformed values in key "${payload.key}" with "${payload.transform}"`);
      return { result: `Transformed values and wrote to ${payload.output}` };
    }

    default:
      log(`❌ Unknown operation: ${payload.operation}`);
      return { error: `Unknown operation: ${payload.operation}` };
  }
}

function getTransformFunction(name) {
  switch (name) {
    case 'toUpperCase': return str => String(str).toUpperCase();
    case 'toLowerCase': return str => String(str).toLowerCase();
    case 'trim': return str => String(str).trim();
    case 'prefix': return str => payload.prefix + String(str);
    case 'suffix': return str => String(str) + payload.suffix;
    default: throw new Error(`Unknown transform: ${name}`);
  }
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
