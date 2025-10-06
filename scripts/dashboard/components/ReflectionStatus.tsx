// <0001faaf> ReflectionStatus Component – displays Cade’s latest reflection in the dashboard ticker

import React from "react";
import { useReflections } from "../hooks/useReflections";

export function ReflectionStatus() {
  const reflection = useReflections();

  if (!reflection) return <span>🧠 Reflecting...</span>;

  const { created_at, summary } = reflection;
  const time = new Date(created_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  const success = Math.round((summary?.success_rate || 0) * 100);

  return (
    <span>
      🧠 Cade last reflected at {time} – Success rate {success}% – Recent:{" "}
      {summary?.recent_actions?.join(", ") || "N/A"}
    </span>
  );
}
