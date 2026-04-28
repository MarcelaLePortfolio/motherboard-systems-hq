import { stabilizeRuntime } from "../../../mirror/runtime/stabilization-layer";
import { createRequire } from "module";

stabilizeRuntime();

const require = createRequire(import.meta.url);

const { createAgentRuntime } = require("../../../mirror/agent");
const matildaModule = require("../../../agents/matilda.ts/matilda.mjs");

const matilda =
  matildaModule.matilda ??
  matildaModule.default ??
  matildaModule;

createAgentRuntime(matilda);
