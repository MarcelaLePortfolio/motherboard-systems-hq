import { stabilizeRuntime } from "../../../mirror/runtime/stabilization-layer";

stabilizeRuntime();

const { createAgentRuntime } = await import("../../../mirror/agent");
const { matilda } = await import("../../../agents/matilda");

createAgentRuntime(matilda);
