import { readFileSync, writeFileSync } from 'fs';

const filePath = './memory/agent_chain_state.json';

function addSampleTasks() {
  let tasks = [];

  try {
    const rawData = readFileSync(filePath, 'utf-8');
    tasks = JSON.parse(rawData);
  } catch (e) {
    console.warn('File not found or empty, starting fresh');
  }

  // Sample new tasks to add
  const newTasks = [
    {
      type: 'write_db',
      table: 'project_tracker',
      row: {
        agent: 'Matilda',
        status: 'Backlog - Set up UI',
        timestamp: '2025-08-05T10:00:00Z',
      },
    },
    {
      type: 'write_db',
      table: 'project_tracker',
      row: {
        agent: 'Effie',
        status: 'In Progress - Connect API',
        timestamp: '2025-08-06T12:30:00Z',
      },
    },
    {
      type: 'write_db',
      table: 'project_tracker',
      row: {
        agent: 'Cade',
        status: 'Completed - Initial commit',
        timestamp: '2025-08-04T08:15:00Z',
      },
    },
  ];

  tasks.push(...newTasks);

  writeFileSync(filePath, JSON.stringify(tasks, null, 2), 'utf-8');
  console.log('Sample tasks added successfully.');
}

addSampleTasks();
