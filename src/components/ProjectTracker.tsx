 
import React from "react";

export default function ProjectTracker() {
  const tasks = [
    { label: "Design new homepage", color: "blue" },
    { label: "Prepare investor presentation", color: "indigo" },
    { label: "Implement authentication", color: "teal" },
    { label: "Conduct user interviews", color: "gray" },
  ];

  return (
    <div className="p-6 rounded-xl bg-white shadow-md">
      <div className="flex justify-center gap-6 mb-4 text-sm font-medium">
        <span className="text-purple-600 underline">Project Activity</span>
        <span className="text-gray-400">Tasks</span>
        <span className="text-gray-400">Settings</span>
      </div>
      <div className="space-y-4">
        {tasks.map(({ label, color }, index) => (
          <div key={index} className="flex justify-between items-center">
            <div className="flex items-center gap-2">
              <span className={`h-3 w-3 rounded-full bg-${color}-500`}></span>
              <span className="text-gray-800">{label}</span>
            </div>
            <button className="px-3 py-1 border rounded-md text-sm text-gray-700 hover:bg-gray-100">
              Request Modification
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
