'use client';

import React from 'react';

type Guidance = {
  classification?: 'success' | 'warning' | 'blocked' | string;
  outcome?: string;
  explanation?: string;
};

type Task = {
  id: string;
  status: string;
  guidance?: Guidance;
};

function getBadgeColor(classification?: string) {
  switch (classification) {
    case 'success':
      return 'bg-green-100 text-green-700';
    case 'warning':
      return 'bg-yellow-100 text-yellow-700';
    case 'blocked':
      return 'bg-red-100 text-red-700';
    default:
      return 'bg-gray-100 text-gray-600';
  }
}

function getStatusColor(status?: string) {
  switch (status) {
    case 'completed':
      return 'text-green-600';
    case 'failed':
      return 'text-red-600';
    case 'running':
      return 'text-blue-600';
    default:
      return 'text-gray-500';
  }
}

export default function ExecutionInspector({ task }: { task: Task }) {
  const guidance = task?.guidance;

  return (
    <div className="p-4 border rounded-xl space-y-4 shadow-sm">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-sm text-gray-500">Task ID</div>
          <div className="font-mono text-sm">{task.id}</div>
        </div>
        <div className={`text-sm font-medium ${getStatusColor(task.status)}`}>
          {task.status}
        </div>
      </div>

      {guidance ? (
        <div className="border rounded-lg p-3 bg-gray-50 space-y-2">
          <div className="flex items-center gap-2">
            <span className={`px-2 py-1 text-xs rounded ${getBadgeColor(guidance.classification)}`}>
              {guidance.classification || 'unknown'}
            </span>
            <span className="text-xs text-gray-400">guidance</span>
          </div>

          {guidance.outcome && (
            <div className="text-sm text-gray-800 font-medium">
              {guidance.outcome}
            </div>
          )}

          {guidance.explanation && (
            <details className="text-sm text-gray-600">
              <summary className="cursor-pointer hover:underline">
                View explanation
              </summary>
              <div className="mt-2 whitespace-pre-wrap">
                {guidance.explanation}
              </div>
            </details>
          )}
        </div>
      ) : (
        <div className="text-xs text-gray-400 italic">
          No guidance available for this task.
        </div>
      )}
    </div>
  );
}
