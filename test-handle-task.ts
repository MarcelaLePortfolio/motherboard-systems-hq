import { handleTask } from './scripts/agents/handleTask.ts';

const task = {
  id: 1,
  type: 'write',
  payload: {
    path: 'memory/test.txt',
    content: 'Hello from handleTask!',
  },
};

handleTask(task)
  .then(console.log)
  .catch(console.error);
