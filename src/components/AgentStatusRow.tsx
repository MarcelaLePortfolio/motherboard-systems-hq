import React from 'react';

const agents = [
  { name: 'Matilda', emoji: '📡', status: 'online' },
  { name: 'Cade', emoji: '🛠️', status: 'online' },
  { name: 'Effie', emoji: '🧾', status: 'online' },
];

export default function AgentStatusRow() {
  return (
    <div className="flex justify-around mb-4">
      {agents.map((agent) => (
        <div key={agent.name} className="flex items-center space-x-2">
          <span className="text-xl">{agent.emoji}</span>
          <span className="text-sm font-medium">{agent.name}</span>
          <span className={`w-2 h-2 rounded-full ${agent.status === 'online' ? 'bg-green-500' : 'bg-gray-400'}`}></span>
        </div>
      ))}
    </div>
  );
}
