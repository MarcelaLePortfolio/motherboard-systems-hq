const fs = require('fs');
const path = require('path');

const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');

function log(msg) {
  console.log(`[CADE] ${msg}`);
}

function writeResume(data) {
  fs.writeFileSync(resumePath, JSON.stringify(data, null, 2));
}

function transformJSON(payload) {
  const inPath = path.join(__dirname, '../../../', payload.input);
  const inputData = JSON.parse(fs.readFileSync(inPath, 'utf8'));

  switch (payload.operation) {
    case 'rename_keys':
      return inputData.map(item => {
        const newItem = {};
        for (const key in item) {
          newItem[payload.mapping[key] || key] = item[key];
        }
        return newItem;
      });

    case 'merge':
      return Array.isArray(payload.inputs)
        ? payload.inputs.map(p => JSON.parse(fs.readFileSync(path.join(__dirname, '../../../', p), 'utf8'))).flat()
        : [];

    case 'filter_values':
      return inputData.filter(item => item[payload.key] === payload.value);

    case 'transform_values':
      return inputData.map(item => {
        if (typeof item[payload.key] !== 'string') return item;
        switch (payload.transform) {
          case 'toUpperCase':
            item[payload.key] = item[payload.key].toUpperCase();
            break;
          case 'toLowerCase':
            item[payload.key] = item[payload.key].toLowerCase();
            break;
          case 'trim':
            item[payload.key] = item[payload.key].trim();
            break;
          case 'prefix':
            item[payload.key] = `${payload.value || ''}${item[payload.key]}`;
            break;
          case 'suffix':
            item[payload.key] = `${item[payload.key]}${payload.value || ''}`;
            break;
        }
        return item;
      });

    case 'group_by':
      return inputData.reduce((acc, item) => {
        const key = item[payload.key];
        if (!acc[key]) acc[key] = [];
        acc[key].push(item);
        return acc;
      }, {});

    case 'sort_by':
      return [...inputData].sort((a, b) => {
        const aVal = a[payload.key];
        const bVal = b[payload.key];
        if (typeof aVal === 'string' && typeof bVal === 'string') {
          return aVal.localeCompare(bVal);
        }
        return aVal > bVal ? 1 : aVal < bVal ? -1 : 0;
      });

    default:
      throw new Error(`Unsupported operation: ${payload.operation}`);
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
