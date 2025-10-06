// <0001fab2> useReflectionHistory – Phase 4 Step 3
// Retrieves Cade's complete reflection history for display panels

import { useEffect, useState } from "react";

export function useReflectionHistory() {
  const [reflections, setReflections] = useState([]);

  async function fetchHistory() {
    try {
      const res = await fetch("/api/reflections/all");
      const data = await res.json();
      setReflections(data);
    } catch (err) {
      console.error("Failed to fetch reflection history:", err);
    }
  }

  useEffect(() => {
    fetchHistory();
    const interval = setInterval(fetchHistory, 60000);
    return () => clearInterval(interval);
  }, []);

  return reflections;
}
