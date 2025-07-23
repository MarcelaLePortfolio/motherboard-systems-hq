import { useEffect } from "react";

export default function TestHydrate() {
  useEffect(() => {
    console.log("✅ React component hydrated!");
  }, []);

  return (
    <div style={{ background: "purple", color: "white", padding: "1rem", fontWeight: "bold" }}>
      🧪 React Hydration Test Component
    </div>
  );
}
