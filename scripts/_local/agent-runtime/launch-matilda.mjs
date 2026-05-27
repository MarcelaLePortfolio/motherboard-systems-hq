import { createAgentRuntime } from "../mirror/agent.mjs";  # adjust path relative to launch-matilda.mjs
import { matilda } from "../../agents/matilda.mjs";

createAgentRuntime(matilda);
