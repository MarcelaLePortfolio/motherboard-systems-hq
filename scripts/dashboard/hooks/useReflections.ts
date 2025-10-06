// <0001f9e0> useReflections – Phase 4 Step 2
// Lightweight polling hook to display Cade's latest self-reflection in UI

import { useEffect, useState } from "react";

export function useReflections() {
  const [reflection, setReflection] = useState<{ created_at: string; summary: any } | null>(null);

  async function fetchReflection() {
    try {
      const res = await fetch("/api/reflections/latest");
      const data = await res.json();
      setReflection(data);
    } catch (err) {
      console.error("Failed to fetch reflection:", err);
    }
  }

  useEffect(() => {
    fetchReflection();
    const interval = setInterval(fetchReflection, 60000); // refresh every 60s
    return () => clearInterval(interval);
  }, []);

  return reflection;
}
