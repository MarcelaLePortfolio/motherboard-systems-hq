import { handleTask } from "../agents/cade";

const task = {
  command: "chain",
  args: {}
};

handleTask(task).then(console.log).catch(console.error);
