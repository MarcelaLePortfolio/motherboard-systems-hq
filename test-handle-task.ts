import { handleTask } from './scripts/agents/handleTask.ts';

const task = {
  type: 'broken_type',
  payload: {
    path: 'unauthorized/path.txt',
  },
};

handleTask(task)
  .then(console.log)
  .catch(console.error);
