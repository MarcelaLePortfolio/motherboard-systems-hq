import { useEffect } from "react";

export default function OpsStreamTicker() {
  useEffect(() => {
    console.log("✅ OpsStreamTicker mounted");
  }, []);
  return (
    <div style={{
      backgroundColor: "transparent",
      padding: "0.5rem 1rem",
      fontWeight: "bold",
      color: "#10b981",
      borderTop: "2px solid #10b981",
    }}>
      ✅ Ops Stream Ticker Active
    </div>
  );
}
