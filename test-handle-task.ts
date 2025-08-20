import { handleTask } from './scripts/agents/handleTask.ts';

const task = {
  id: 42, // ✅ required number
  type: 'write', // ✅ valid type
  payload: {
    path: 'test.txt', // ✅ relative, safe path
    content: 'Testing graceful shutdown simulation!', // ✅ optional content
  },
};

handleTask(task)
  .then(console.log)
  .catch(console.error);
