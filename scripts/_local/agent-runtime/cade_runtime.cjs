const fs = require('fs');
const path = require('path');

const statePath = path.join(__dirname, '../../../memory/agent_chain_state.json');
const resumePath = path.join(__dirname, '../../../memory/resume_payload.json');

function log(msg) {
  console.log(msg);
}

function writeResume(data) {
  fs.writeFileSync(resumePath, JSON.stringify(data, null, 2));
}

function transformJSON(payload) {
  const inputPath = path.join(__dirname, '../../../', payload.input);
  const outputPath = path.join(__dirname, '../../../', payload.output);
  const raw = fs.readFileSync(inputPath, 'utf8');
  const data = JSON.parse(raw);

  switch (payload.operation) {
    case 'rename_keys':
      return data.map(item => {
        const newItem = {};
        for (const key in item) {
          newItem[payload.mapping[key] || key] = item[key];
        }
        return newItem;
      });

    case 'filter_values':
      return data.filter(item => item[payload.key] === payload.value);

    case 'transform_values':
      return data.map(item => {
        const value = item[payload.key];
        if (typeof value !== 'string') return item;
        switch (payload.transform) {
          case 'toLowerCase':
            item[payload.key] = value.toLowerCase();
            break;
          case 'toUpperCase':
            item[payload.key] = value.toUpperCase();
            break;
          case 'trim':
            item[payload.key] = value.trim();
            break;
          case 'prefix':
            item[payload.key] = `${payload.prefix || ''}${value}`;
            break;
          case 'suffix':
            item[payload.key] = `${value}${payload.suffix || ''}`;
            break;
        }
        return item;
      });

    case 'group_by':
      return data.reduce((acc, item) => {
        const groupKey = item[payload.key];
        if (!acc[groupKey]) acc[groupKey] = [];
        acc[groupKey].push(item);
        return acc;
      }, {});

    default:
      throw new Error(`Unknown operation: ${payload.operation}`);
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
