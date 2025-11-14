// <0001faf8> Phase 9.2 — Reflection pacing script (≈1 Hz cinematic playback)
// Ensures dashboard reflections appear smoothly, one per second.
const REFLECTION_INTERVAL = 1000; // 1 Hz
let reflectionQueue = [];
let isDisplaying = false;
const evtSource = new EventSource("http://localhost:3101/events/reflections");
evtSource.onmessage = (e) => {
    try {
        const data = JSON.parse(e.data);
        if (data && data.content) {
            reflectionQueue.push(data.content);
            processQueue();
        }
    }
    catch (err) {
        console.error("⚠️ Reflection pacing parse error:", e.data);
    }
};
function processQueue() {
    if (isDisplaying || reflectionQueue.length === 0)
        return;
    isDisplaying = true;
    const reflection = reflectionQueue.shift();
    const logContainer = document.getElementById("recentLogs");
    if (logContainer) {
        const entry = document.createElement("div");
        entry.className = "reflection-entry";
        entry.textContent = reflection;
        entry.style.opacity = "0";
        entry.style.transition = "opacity 0.8s ease-in-out";
        logContainer.prepend(entry);
        requestAnimationFrame(() => (entry.style.opacity = "1"));
    }
    setTimeout(() => {
        isDisplaying = false;
        if (reflectionQueue.length > 0)
            processQueue();
    }, REFLECTION_INTERVAL);
}
export {};
