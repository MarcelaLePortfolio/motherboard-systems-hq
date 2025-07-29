/**

Effie Launcher – Fixed Import Path

Starts Effie using the shared createAgentRuntime wrapper.
*/

import { createAgentRuntime } from "../../mirror/agent";
import { effie } from "../../agents/effie"; // ✅ Corrected path

createAgentRuntime(effie);
