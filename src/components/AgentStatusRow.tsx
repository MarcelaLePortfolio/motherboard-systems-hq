import React from 'react';

const agents = [
  { name: 'Cade', icon: '🧰', status: 'online' },
  { name: 'Effie', icon: '🖥️', status: 'offline' },
  { name: 'Matilda', icon: '🪶', status: 'online' },
];

const statusColor = {
  online: 'bg-green-500',
  offline: 'bg-red-500',
};

export default function AgentStatusRow() {
  return (
    <div className="flex justify-center space-x-6 mt-4 text-sm font-medium">
      {agents.map(agent => (
        <div key={agent.name} className="flex items-center space-x-1">
          <span>{agent.icon}</span>
          <span>{agent.name}:</span>
          <span className={`w-2.5 h-2.5 rounded-full ${statusColor[agent.status]}`}></span>
        </div>
      ))}
    </div>
  );
}
