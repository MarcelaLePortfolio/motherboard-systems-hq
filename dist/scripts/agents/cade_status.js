import { broadcastLogUpdate } from "../../routes/eventsAgents";
let cadeStatus = "idle";
export function getCadeStatus() {
    return cadeStatus;
}
export function setCadeStatus(newStatus) {
    cadeStatus = newStatus;
    console.log(`⚙️ Cade status changed to: ${newStatus}`);
    try {
        broadcastLogUpdate({
            timestamp: new Date().toISOString(),
            source: "Cade",
            message: `Status changed to ${newStatus}`,
        });
    }
    catch (err) {
        console.error("❌ broadcastLogUpdate failed (status):", err);
    }
}
