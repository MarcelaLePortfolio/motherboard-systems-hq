const fs = require('fs');
const path = require('path');

const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');
const logPath = path.join(__dirname, '../../../memory/chaining_runtime_log.json');

function log(message) {
  const logData = { timestamp: new Date().toISOString(), message };
  fs.appendFileSync(logPath, JSON.stringify(logData) + '\n');
}

function writeResume(data) {
  fs.writeFileSync(resumePath, JSON.stringify(data, null, 2));
}

function handleTask(task) {
  const { type, payload } = task;

  switch (type) {
    case 'echo':
      log(`🗣️ ${payload.message}`);
      return { result: payload.message };

    case 'write_file':
      fs.writeFileSync(path.join(__dirname, '../../../', payload.filename), payload.content);
      log(`📝 Wrote file: ${payload.filename}`);
      return { result: `Wrote file ${payload.filename}` };

    case 'append_log':
      const logLine = `[${new Date().toISOString()}] ${payload.content || 'No content'}`;
      const appendPath = path.join(__dirname, '../../../', payload.filename || 'cade_append_log.txt');
      fs.appendFileSync(appendPath, logLine + '\n');
      log(`📝 Appended to file: ${appendPath}`);
      return { result: `Appended to ${payload.filename}` };

    case 'transform_json': {
      try {
        const inputPath = path.join(__dirname, '../../../', payload.input);
        const outputPath = path.join(__dirname, '../../../', payload.output);
        const data = JSON.parse(fs.readFileSync(inputPath, 'utf8'));

        let result;
        if (payload.operation === 'filter_keys') {
          result = data.map(item =>
            Object.fromEntries(payload.keys.map(k => [k, item[k]]))
          );
        } else if (payload.operation === 'rename_keys') {
          result = data.map(item => {
            const renamed = {};
            for (const [oldKey, newKey] of Object.entries(payload.mapping)) {
              if (item.hasOwnProperty(oldKey)) {
                renamed[newKey] = item[oldKey];
              }
            }
            return renamed;
          });
        } else {
          throw new Error(`Unsupported operation: ${payload.operation}`);
        }

        fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));
        log(`🔄 Transformed JSON with operation: ${payload.operation}`);
        return { result: `Transformed JSON and wrote to ${payload.output}` };

      } catch (err) {
        log(`❌ Error transforming JSON: ${err.message}`);
        return { error: err.message };
      }
    }

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
