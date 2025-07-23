import React from "react";

const Badge = () => {
  return (
    <div
      style={{
        backgroundColor: "#1F2937", // neutral-800 for a more refined dark tone
        padding: "0.75rem 1.25rem",
        borderRadius: "0.5rem",
        color: "white",
        fontWeight: "600",
        fontSize: "1rem",
        display: "inline-block",
        textAlign: "center",
        maxWidth: "100%",
      }}
    >
      🛰️ Systems Console Active
    </div>
  );
};

export default Badge;
