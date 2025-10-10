 
import React from 'react';

const tasks = [
  { label: "Design new homepage", color: "bg-blue-600" },
  { label: "Prepare investor presentation", color: "bg-blue-600" },
  { label: "Implement authentication", color: "bg-teal-400" },
  { label: "Conduct user interviews", color: "bg-gray-400" },
];

export default function TaskList() {
  return (
    <ul className="space-y-3">
      {tasks.map((task) => (
        <li key={task.label} className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <span className={`w-3 h-3 rounded-full ${task.color}`}></span>
            <span>{task.label}</span>
          </div>
          <button className="px-3 py-1 text-sm border border-gray-300 rounded-md hover:bg-gray-50">
            Request Modification
          </button>
        </li>
      ))}
    </ul>
  );
}
