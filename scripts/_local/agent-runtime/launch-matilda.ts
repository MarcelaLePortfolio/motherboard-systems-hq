import path from "path";
import { createAgentRuntime } from "../../../mirror/agent";

// absolute resolution (TSX-safe under PM2)
import { matilda } from path.resolve(process.cwd(), "agents/matilda");

createAgentRuntime(matilda);
