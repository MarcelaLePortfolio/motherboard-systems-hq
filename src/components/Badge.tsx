import React from "react";

const Badge = () => {
  return (
    <div
      style={{
        backgroundColor: "#10B981", // emerald-500
        padding: "0.75rem 1.25rem",
        borderRadius: "0.5rem",
        color: "white",
        fontWeight: "600",
        fontSize: "1rem",
        display: "inline-block",
        textAlign: "center",
      }}
    >
      ✅ Hello from React!
    </div>
  );
};

export default Badge;
