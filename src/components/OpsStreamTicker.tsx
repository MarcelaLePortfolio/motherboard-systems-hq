import { useEffect, useState } from "react";

export default function OpsStreamTicker() {
  const [tick, setTick] = useState(0);
  useEffect(() => {
    const interval = setInterval(() => setTick((t) => t + 1), 1000);
    return () => clearInterval(interval);
  }, []);
  return (
    <div style={{
      padding: "0.5rem 1rem",
      fontWeight: "bold",
      color: "white",
      backgroundColor: "#0ea5e9",
      borderRadius: "0.25rem",
      width: "fit-content",
      margin: "0 auto"
    }}>
      🔄 OpsStream tick: {tick}
    </div>
  );
}
