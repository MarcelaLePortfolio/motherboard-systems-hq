/**

Cade Launcher – Fixed Import Path

Starts Cade using the shared createAgentRuntime wrapper.
*/

import { createAgentRuntime } from "../../mirror/agent";
import { cade } from "../../agents/cade"; // ✅ Corrected path

createAgentRuntime(cade);
