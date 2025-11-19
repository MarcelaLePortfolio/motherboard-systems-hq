// <0001fb33> Phase 10.0 — Demo Pre-Warm Sequence
import { execSync } from "child_process";
function log(msg) {
    console.log("⚙️", msg);
}
log("Warming up agents...");
try {
    execSync("curl -s -X POST http://localhost:3000/matilda -H 'Content-Type: application/json' -d '{\"message\":\"Matilda status check\"}'");
    execSync("curl -s -X POST http://localhost:3000/delegate -H 'Content-Type: application/json' -d '{\"instruction\":\"Matilda, perform system warmup\"}'");
    log("✅ Matilda responding.");
}
catch {
    log("⚠️ Matilda unresponsive.");
}
try {
    execSync("curl -I http://localhost:3101/events/reflections");
    log("✅ Reflections stream reachable.");
}
catch {
    log("⚠️ Reflections SSE unavailable.");
}
try {
    execSync("curl -I http://localhost:3201/events/ops");
    log("✅ OPS stream reachable.");
}
catch {
    log("⚠️ OPS SSE unavailable.");
}
log("Demo pre-warm complete.");
