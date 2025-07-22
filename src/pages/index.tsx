import React from 'react';
import AgentStatusRow from '../components/AgentStatusRow';

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-50 text-gray-900 p-6">
      <h1 className="text-3xl font-bold text-center mb-8">Welcome to Matilda</h1>
      <AgentStatusRow />
      <div className="mt-10">
        <div className="flex space-x-6 justify-center border-b pb-2 mb-3 font-medium">
          <button className="text-violet-600 border-b-2 border-violet-600 pb-1">Project Activity</button>
          <button className="text-gray-600">Tasks</button>
          <button className="text-gray-600">Settings</button>
        </div>

        <h2 className="text-xl font-semibold mb-4">Project Tracker</h2>
        <ul className="space-y-3">
          {[
            { label: "Design new homepage", color: "bg-blue-600" },
            { label: "Prepare investor presentation", color: "bg-blue-600" },
            { label: "Implement authentication", color: "bg-teal-400" },
            { label: "Conduct user interviews", color: "bg-gray-400" },
          ].map((task) => (
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
      </div>
    </main>
  );
}
