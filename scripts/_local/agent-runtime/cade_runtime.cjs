const fs = require('fs');
const path = require('path');
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');

function log(message) {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${message}`);
}

function writeResume(payload) {
  fs.writeFileSync(resumePath, JSON.stringify(payload, null, 2));
}

function filterValues(data, key, value) {
  return data.filter(entry => entry[key] === value);
}

function filterKeys(data, keys) {
  return data.map(entry => {
    const filtered = {};
    keys.forEach(k => {
      if (k in entry) filtered[k] = entry[k];
    });
    return filtered;
  });
}

function renameKeys(data, mapping) {
  return data.map(entry => {
    const renamed = {};
    for (const key in entry) {
      renamed[mapping[key] || key] = entry[key];
    }
    return renamed;
  });
}

function mergeJSON(values) {
  const [first, ...rest] = values;
  if (Array.isArray(first)) return values.flat();
  return Object.assign({}, ...values);
}

async function handleTask(task) {
  const { type, payload } = task;

  switch (type) {
    case 'echo':
      log(`📣 ${payload.message}`);
      return { echoed: payload.message };

    case 'write_file':
      fs.writeFileSync(path.join(__dirname, '../../../', payload.filename), payload.content);
      log(`✍️  Wrote file: ${payload.filename}`);
      return { result: `Wrote ${payload.filename}` };

    case 'append_log':
      fs.appendFileSync(path.join(__dirname, '../../../', payload.filename), `[${new Date().toISOString()}] ${payload.content}\n`);
      log(`📌 Appended to: ${payload.filename}`);
      return { result: `Appended to ${payload.filename}` };

    case 'transform_json': {
      try {
        const inputPath = path.join(__dirname, '../../../', payload.input);
        const outputPath = path.join(__dirname, '../../../', payload.output);
        const raw = fs.readFileSync(inputPath, 'utf8');
        let data = JSON.parse(raw);

        if (payload.operation === 'filter_keys') {
          data = filterKeys(data, payload.keys);
        } else if (payload.operation === 'rename_keys') {
          data = renameKeys(data, payload.mapping);
        } else if (payload.operation === 'filter_values') {
          data = filterValues(data, payload.key, payload.value);
        }

        fs.writeFileSync(outputPath, JSON.stringify(data, null, 2));
        log(`🔧 Transformed JSON (${payload.operation})`);
        return { result: `Transformed JSON and wrote to ${payload.output}` };
      } catch (err) {
        log(`❌ Error in transform_json: ${err.message}`);
        return { error: err.message };
      }
    }

    case 'fetch_json': {
      try {
        const response = await fetch(payload.url);
        const data = await response.json();
        const outPath = path.join(__dirname, '../../../', payload.output);
        fs.writeFileSync(outPath, JSON.stringify(data, null, 2));
        log(`🌐 Fetched JSON from ${payload.url}`);
        return { result: `Fetched and saved to ${payload.output}` };
      } catch (err) {
        log(`❌ Error fetching JSON: ${err.message}`);
        return { error: err.message };
      }
    }

    case 'merge_json': {
      try {
        const values = payload.inputs.map(filename => {
          const raw = fs.readFileSync(path.join(__dirname, '../../../', filename), 'utf8');
          return JSON.parse(raw);
        });
        const merged = mergeJSON(values);
        const outPath = path.join(__dirname, '../../../', payload.output);
        fs.writeFileSync(outPath, JSON.stringify(merged, null, 2));
        log(`<0001f9e9> Merged JSON from ${payload.inputs.length} sources`);
        return { result: `Merged into ${payload.output}` };
      } catch (err) {
        log(`❌ Error merging JSON: ${err.message}`);
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
