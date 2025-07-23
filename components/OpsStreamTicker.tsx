import React, { useEffect } from "react";

export default function OpsStreamTicker() {
  useEffect(() => {
    console.log("✅ OpsStreamTicker hydrated and rendered");
  }, []);

  return (
    <div className="bg-gray-800 text-white text-sm py-2 px-4 font-mono flex justify-between items-center shadow-md">
      <span>🚦 Ops Stream: Cade merged snapshot · Effie updated state</span>
      <a href="/ops/history" className="underline text-blue-300 hover:text-blue-100 ml-4">View All</a>
    </div>
  );
}
