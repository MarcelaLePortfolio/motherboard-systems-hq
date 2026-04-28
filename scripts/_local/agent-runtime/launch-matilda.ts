import path from "path";
import { createAgentRuntime } from "../../../mirror/agent";
import { matilda } from "../../../agents/matilda";

// force stable resolution context for tsx + pm2
process.chdir(path.resolve(__dirname, "../../.."));

createAgentRuntime(matilda);
