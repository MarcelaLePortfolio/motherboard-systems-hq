import http from "http";

export function broadcastReflections() {
  try {
    const req = http.request(
      {
        hostname: "localhost",
        port: 3101,
        path: "/trigger",
        method: "POST",
      },
      (res) => {
        res.on("data", () => {});
        res.on("end", () => {
          console.log("📡 Reflections broadcast triggered.");
        });
      }
    );
    req.on("error", (err) => {
      console.error("❌ SSE broadcast error:", err.message);
    });
    req.end();
  } catch (err) {
    console.error("❌ Failed to broadcast reflections:", err);
  }
}
