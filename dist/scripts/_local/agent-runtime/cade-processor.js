import { startCadeTaskProcessor } from "./utils/cade_task_processor.js";
startCadeTaskProcessor();
console.log(" Cade Task Processor started."); // --- Keep the process alive ---setInterval(() => {}, 1 << 30);
