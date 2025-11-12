import { broadcastLogUpdate } from "../../routes/eventsAgents";

let cadeStatus: "idle" | "busy" | "online" = "idle";

export function getCadeStatus() {
  return cadeStatus;
}

export function setCadeStatus(newStatus: typeof cadeStatus) {
  cadeStatus = newStatus;
  console.log(`⚙️ Cade status changed to: ${newStatus}`);
  try {
    broadcastLogUpdate({
      timestamp: new Date().toISOString(),
      source: "Cade",
      message: `Status changed to ${newStatus}`,
    });
  } catch (err) {
    console.error("❌ broadcastLogUpdate failed (status):", err);
  }
}
