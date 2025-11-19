import { createAgentRuntime } from "../../mirror/agent";
import { cade } from "../../agents/cade";
import { readChainState, writeChainState } from "../utils/chainState";
import { routeTask } from "../handlers/taskRouter";
async function checkAndRunTaskFromState() {
    const state = await readChainState();
    if (state?.agent !== "Cade" || state?.status !== "Assigned")
        return;
    console.log("🎯 [CADE] Assigned task received:", state);
    try {
        const result = await routeTask(state);
        const updated = {
            ...state,
            status: "Completed",
            result,
            ts: Date.now()
        };
        await writeChainState(updated);
        console.log("✅ [CADE] Task completed:", result);
    }
    catch (err) {
        const failed = {
            ...state,
            status: "Failed",
            error: String(err),
            ts: Date.now()
        };
        await writeChainState(failed);
        console.error("❌ [CADE] Task failed:", err);
    }
}
checkAndRunTaskFromState(); // fire once per startup for now
createAgentRuntime(cade);
