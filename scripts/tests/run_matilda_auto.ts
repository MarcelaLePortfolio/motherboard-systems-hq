import { matildaCommandRouter } from "../agents/matilda";

matildaCommandRouter("auto", {
  description: "please delete the backup folder",
}).then(console.log).catch(console.error);
