const fs = require('fs');
const path = require('path');

const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');

function log(msg) {
  console.log(`[CADE] ${msg}`);
}

function writeResume(result) {
  fs.writeFileSync(resumePath, JSON.stringify(result, null, 2));
}

function transformJSON(payload) {
  const { input, output, operation, key, value, transform } = payload;
  const raw = fs.readFileSync(path.join(__dirname, '../../../', input), 'utf8');
  const data = JSON.parse(raw);

  switch (operation) {
    case 'rename_keys':
      return data.map(obj =>
        Object.fromEntries(Object.entries(obj).map(([k, v]) => [payload.mapping[k] || k, v]))
      );

    case 'filter_values':
      return data.filter(obj => obj[key] === value);

    case 'transform_values':
      return data.map(obj => {
        if (typeof obj[key] === 'string') {
          switch (transform) {
            case 'toUpperCase': obj[key] = obj[key].toUpperCase(); break;
            case 'toLowerCase': obj[key] = obj[key].toLowerCase(); break;
            case 'trim': obj[key] = obj[key].trim(); break;
            case 'prefix': obj[key] = `${value}${obj[key]}`; break;
            case 'suffix': obj[key] = `${obj[key]}${value}`; break;
          }
        }
        return obj;
      });

    case 'group_by':
      return data.reduce((acc, obj) => {
        const group = obj[key];
        if (!acc[group]) acc[group] = [];
        acc[group].push(obj);
        return acc;
      }, {});

    case 'sort_by':
      return [...data].sort((a, b) => {
        const valA = (a[key] || '').toString().toLowerCase();
        const valB = (b[key] || '').toString().toLowerCase();
        return valA.localeCompare(valB);
      });

    default:
      throw new Error(`Unknown operation: ${operation}`);
  }
}

function handleTask(task) {
  try {
    switch (task.type) {
      case 'transform_json':
        const result = transformJSON(task.payload);
        fs.writeFileSync(
          path.join(__dirname, '../../../', task.payload.output),
          JSON.stringify(result, null, 2)
        );
        return { result: `Wrote to ${task.payload.output}` };
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
