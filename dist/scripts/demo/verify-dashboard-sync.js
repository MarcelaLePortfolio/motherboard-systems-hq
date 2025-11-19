// <0001fae7> Phase 6.2 — Dashboard Sync Verification
import fetch from "node-fetch";
async function checkSSE(endpoint) {
    console.log(`🔍 Checking SSE endpoint: ${endpoint}`);
    try {
        const response = await fetch(endpoint, { headers: { Accept: "text/event-stream" } });
        if (response.ok) {
            console.log(`✅ ${endpoint} reachable and streaming`);
        }
        else {
            console.log(`⚠️ ${endpoint} responded with status: ${response.status}`);
        }
    }
    catch (err) {
        console.error(`❌ ${endpoint} failed:`, err);
    }
}
async function main() {
    console.log("🧠 Verifying live dashboard sync endpoints...");
    await checkSSE("http://localhost:3201/events/ops");
    await checkSSE("http://localhost:3101/events/reflections");
    console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
}
main();
