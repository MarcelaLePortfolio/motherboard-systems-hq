// <0001fab3> ReflectionsPanel – displays Cade’s full reflection history

import React from "react";
import { useReflectionHistory } from "../hooks/useReflectionHistory";

export function ReflectionsPanel() {
  const reflections = useReflectionHistory();

  if (!reflections.length)
    return <div><0001f9e0> No reflections recorded yet.</div>;

  return (
    <div className="reflections-panel">
      <h3>🧠 Cade Reflection History</h3>
      <ul>
        {reflections.map((r) => {
          const time = new Date(r.created_at).toLocaleString();
          const success = Math.round((r.summary?.success_rate || 0) * 100);
          return (
            <li key={r.id}>
              <strong>{time}</strong> — Success {success}% — Recent:{" "}
              {r.summary?.recent_actions?.join(", ") || "N/A"}
            </li>
          );
        })}
      </ul>
    </div>
  );
}
