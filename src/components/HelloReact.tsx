 
import { useEffect } from "react";
export default function HelloReact() {
  useEffect(() => {
    console.log("✅ HelloReact mounted");
  }, []);
  return (
    <div style={{ backgroundColor: "#10b981", color: "white", padding: "1rem", fontWeight: "bold" }}>
      ✅ Hello from React!
    </div>
  );
}
