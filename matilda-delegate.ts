import { matildaTaskRunner } from "../scripts/agents/matilda";

matildaTaskRunner({
  type: "install",
  package: "chalk"
}).then(console.log).catch(console.error);
