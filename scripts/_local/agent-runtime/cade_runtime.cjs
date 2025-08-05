const fs = require('fs');
const path = require('path');
const https = require('https');
const http = require('http');

const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');

function log(msg) {
  console.log(`${new Date().toISOString()} ${msg}`);
}

function writeResume(result) {
  fs.writeFileSync(resumePath, JSON.stringify(result, null, 2));
}

function readJSON(filePath) {
  const raw = fs.readFileSync(filePath, 'utf8');
  return JSON.parse(raw);
}

function fetchJSON(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith('https') ? https : http;
    client.get(url, res => {
      let data = '';
      res.on('data', chunk => (data += chunk));
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve(json);
        } catch (err) {
          reject(err);
        }
      });
    }).on('error', err => reject(err));
  });
}

function handleTask(task) {
  const { type, payload } = task;

  switch (type) {
    case 'echo':
      log(`🗣️ Echo: ${payload.message}`);
      return { result: payload.message };

    case 'write_file':
      fs.writeFileSync(path.join(__dirname, '../../../', payload.filename), payload.content);
      log(`📄 Wrote file: ${payload.filename}`);
      return { result: `Wrote file: ${payload.filename}` };

    case 'append_log':
      const logLine = `[${new Date().toISOString()}] ${payload.content || 'No content'}`;
      const appendPath = path.join(__dirname, '../../../', payload.filename || 'cade_append_log.txt');
      fs.appendFileSync(appendPath, logLine + '\n');
      log(`📝 Appended to file: ${appendPath}`);
      return { result: `Appended to ${payload.filename}` };

    case 'transform_json': {
      try {
        const inputPath = payload.input?.startsWith('http') ? null : path.join(__dirname, '../../../', payload.input);
        const sourcePromise = inputPath ? Promise.resolve(readJSON(inputPath)) : fetchJSON(payload.input);

        return sourcePromise.then(source => {
          const transformed = source.map(entry => {
            if (payload.operation === 'filter_keys') {
              const filtered = {};
              payload.keys.forEach(k => {
                if (entry.hasOwnProperty(k)) filtered[k] = entry[k];
              });
              return filtered;
            }

            if (payload.operation === 'rename_keys') {
              const renamed = {};
              Object.keys(entry).forEach(k => {
                const newKey = payload.mapping[k] || k;
                renamed[newKey] = entry[k];
              });
              return renamed;
            }

            throw new Error(`Unsupported transform operation: ${payload.operation}`);
          });

          const outPath = path.join(__dirname, '../../../', payload.output);
          fs.writeFileSync(outPath, JSON.stringify(transformed, null, 2));
          log(`🔄 Transformed JSON from ${payload.input} -> ${payload.output}`);
          return { result: `Transformed JSON and wrote to ${payload.output}` };
        }).catch(err => {
          log(`❌ Error fetching or transforming JSON: ${err.message}`);
          return { error: err.message };
        });
      } catch (err) {
        log(`❌ Error in transform_json: ${err.message}`);
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
