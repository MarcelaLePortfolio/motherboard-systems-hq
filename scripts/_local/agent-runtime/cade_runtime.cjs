const path = require('path'); // Import Node's path module for file path operations
const fs = require('fs');

function log(...args) {
  console.log(...args);
}

function readJSON(filePath) {
  try {
    const absPath = path.join(__dirname, '../../../', filePath);
    const content = fs.readFileSync(absPath, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    log(`❌ Failed to read JSON file at ${filePath}: ${error.message}`);
    return null;
  }
}

function writeJSON(filePath, data) {
  try {
    const absPath = path.join(__dirname, '../../../', filePath);
    fs.writeFileSync(absPath, JSON.stringify(data, null, 2), 'utf8');
    log(`✅ Wrote JSON to ${filePath}`);
  } catch (error) {
    log(`❌ Failed to write JSON file at ${filePath}: ${error.message}`);
  }
}

function sortBy(array, key) {
  return array.slice().sort((a, b) => {
    if (a[key] < b[key]) return -1;
    if (a[key] > b[key]) return 1;
    return 0;
  });
}

function transformValues(array, key, transform) {
  return array.map(item => {
    const val = item[key];
    let newVal = val;
    switch (transform) {
      case 'toUpperCase':
        newVal = typeof val === 'string' ? val.toUpperCase() : val;
        break;
      case 'toLowerCase':
        newVal = typeof val === 'string' ? val.toLowerCase() : val;
        break;
      // Add more transformations as needed
      default:
        newVal = val;
    }
    return { ...item, [key]: newVal };
  });
}

function filterValues(array, key, value) {
  return array.filter(item => item[key] === value);
}

function groupBy(array, key) {
  return array.reduce((acc, item) => {
    const groupKey = item[key];
    if (!acc[groupKey]) acc[groupKey] = [];
    acc[groupKey].push(item);
    return acc;
  }, {});
}

function transformJSON(payload) {
  log('transformJSON called with payload:', payload);
  const inputData = readJSON(payload.input);
  if (!inputData) return { error: `Failed to read input file: ${payload.input}` };

  let result;
  switch (payload.operation) {
    case 'sort_by':
      result = sortBy(inputData, payload.key);
      break;
    case 'transform_values':
      result = transformValues(inputData, payload.key, payload.transform);
      break;
    case 'filter_values':
      result = filterValues(inputData, payload.key, payload.value);
      break;
    case 'group_by':
      result = groupBy(inputData, payload.key);
      break;
    default:
      return { error: `Unknown operation: ${payload.operation}` };
  }

  writeJSON(payload.output, result);
  return { success: true, output: payload.output };
}

function handleTask(task) {
  try {
    log('handleTask received:', task);
    if (Array.isArray(task.chain)) {
      let lastResult = null;
      for (const subtask of task.chain) {
        if (subtask.type === 'transform_json') {
          lastResult = transformJSON(subtask.payload);
          if (lastResult.error) return lastResult;
        } else {
          return { error: `Unknown task type: ${subtask.type}` };
        }
      }
      return lastResult;
    }
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

function writeResume(data) {
  const resumePath = path.join(__dirname, '../../../memory/agent_chain_resume.json');
  fs.writeFileSync(resumePath, JSON.stringify(data, null, 2), 'utf8');
  log(`✅ Wrote resume to ${resumePath}`);
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
