import { useEffect } from "react";
export default function OpsStreamTicker() {
  useEffect(() => {
    console.log("✅ OpsStreamTicker mounted");
  }, []);
  return (
    <div style={{
      backgroundColor: "#1a1a1a",
      color: "white",
      padding: "0.5rem 1rem",
      fontFamily: "monospace",
      fontSize: "0.875rem",
      borderTop: "1px solid #333",
      borderBottom: "1px solid #333"
    }}>
      LIVE OP LOG: Systems nominal • AI Core synced • Dashboard stable
    </div>
  );
}
