import { useEffect } from "react";

export default function OpsStreamTicker() {
  useEffect(() => {
    console.log("✅ OpsStreamTicker mounted");
  }, []);

  return (
    <div
      style={{
        padding: "0.75rem 1rem",
        fontWeight: "bold",
        color: "white",
        backgroundColor: "#111827", // ✅ Dark background
        borderRadius: "0.5rem",
        maxWidth: "800px",
        width: "100%",
        textAlign: "center",
      }}
    >
      🛰️ SYSTEMS ONLINE — All agents reporting in real-time
    </div>
  );
}
