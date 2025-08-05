const fs = require('fs');
const path = require('path');
const fetch = require('node-fetch');

const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');

function log(msg) {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${msg}`);
}

function writeResume(data) {
  fs.writeFileSync(resumePath, JSON.stringify(data, null, 2));
}

function loadJSON(fileOrUrl) {
  if (fileOrUrl.startsWith('http://') || fileOrUrl.startsWith('https://')) {
    return fetch(fileOrUrl).then(res => res.json());
  } else {
    const absPath = path.join(__dirname, '../../../', fileOrUrl);
    return Promise.resolve(JSON.parse(fs.readFileSync(absPath, 'utf8')));
  }
}

function mergeJSON(values) {
  if (!Array.isArray(values)) throw new Error('Expected an array of JSON values.');
  if (values.every(v => Array.isArray(v))) {
    return values.flat();
  } else if (values.every(v => typeof v === 'object' && !Array.isArray(v))) {
    return Object.assign({}, ...values);
  } else {
    throw new Error('JSON types must match and be either all arrays or all objects.');
  }
}

async function handleTask(task) {
  const { type, payload } = task;

  switch (type) {
    case 'echo':
      log(`🔊 Echoing: ${payload.message}`);
      return { echoed: payload.message };

    case 'write_file':
      fs.writeFileSync(path.join(__dirname, '../../../', payload.filename), payload.content);
      log(`📝 Wrote to file: ${payload.filename}`);
      return { result: `Wrote to ${payload.filename}` };

    case 'append_log':
      const logLine = `[${new Date().toISOString()}] ${payload.content || 'No content'}`;
      const appendPath = path.join(__dirname, '../../../', payload.filename || 'cade_append_log.txt');
      fs.appendFileSync(appendPath, logLine + '\n');
      log(`📌 Appended to file: ${appendPath}`);
      return { result: `Appended to ${payload.filename}` };

    case 'transform_json': {
      const inputPath = payload.input;
      const outputPath = path.join(__dirname, '../../../', payload.output);
      const jsonData = await loadJSON(inputPath);

      let transformed;
      if (payload.operation === 'filter_keys') {
        transformed = jsonData.map(entry =>
          Object.fromEntries(payload.keys.map(k => [k, entry[k]]).filter(([_, v]) => v !== undefined))
        );
      } else if (payload.operation === 'rename_keys') {
        transformed = jsonData.map(entry =>
          Object.fromEntries(Object.entries(entry).map(([k, v]) =>
            [payload.mapping[k] || k, v]
          ))
        );
      } else {
        throw new Error(`Unknown transform operation: ${payload.operation}`);
      }

      fs.writeFileSync(outputPath, JSON.stringify(transformed, null, 2));
      log(`🔄 Transformed JSON with operation: ${payload.operation}`);
      return { result: `Transformed JSON and wrote to ${payload.output}` };
    }

    case 'merge_json': {
      const values = await Promise.all(payload.inputs.map(loadJSON));
      const merged = mergeJSON(values);
      const outPath = path.join(__dirname, '../../../', payload.output);
      fs.writeFileSync(outPath, JSON.stringify(merged, null, 2));
      log(`🧩 Merged JSON from ${payload.inputs.length} sources`);
      return { result: `Merged into ${payload.output}` };
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
    const resultPromise = handleTask(task);
    Promise.resolve(resultPromise).then(writeResume).catch(err => {
      log(`❌ Async error: ${err.message}`);
      writeResume({ error: err.message });
    });
  } catch (err) {
    log(`❌ Sync error: ${err.message}`);
    writeResume({ error: err.message });
  }
}

processTask();
