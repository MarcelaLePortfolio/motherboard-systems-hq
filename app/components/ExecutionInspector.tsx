
'use client';

import React from 'react';

type Guidance = {

  classification?: 'success' | 'warning' | 'blocked' | string;

  outcome?: string;

  explanation?: string;

  run_id?: string;

  task_id?: string;

  actor?: string;

  source?: string;

  completed_at?: string;

  outcome_preview?: string;

  explanation_preview?: string;

  communicationResult?: {

    outcome?: {

      tier?: string;

      content?: string;

      purpose?: string;

      visibility?: string;

    };

    explanation?: {

      tier?: string;

      content?: string;

      purpose?: string;

      visibility?: string;

      persistence?: string;

    };

    systemTrace?: {

      tier?: string;

      content?: Record<string, unknown>;

      purpose?: string;

      visibility?: string;

      persistence?: string;

    };

  };

};

type Task = {

  id: string;

  status: string;

  claimed_by?: string;

  updated_at?: string;

  outcome_preview?: string;

  explanation_preview?: string;

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

function EvidenceRow({ label, value }: { label: string; value?: React.ReactNode }) {

  if (value === undefined || value === null || value === '') return null;

  return (

    <div className="flex items-start justify-between gap-3 text-xs">

      <div className="text-gray-500">{label}</div>

      <div className="max-w-[70%] break-words text-right font-mono text-gray-700">

        {value}

      </div>

    </div>

  );

}

export default function ExecutionInspector({ task }: { task: Task }) {

  const guidance = task?.guidance;

  const evidence = {

    runId: guidance?.run_id,

    taskId: guidance?.task_id || task.id,

    actor: guidance?.actor || task.claimed_by,

    source: guidance?.source,

    completedAt: guidance?.completed_at,

    updatedAt: task.updated_at,

    outcomePreview: guidance?.outcome_preview || task.outcome_preview,

    explanationPreview: guidance?.explanation_preview || task.explanation_preview,

    systemTrace: guidance?.communicationResult?.systemTrace,

  };

  return (

    <div className="p-4 border rounded-xl space-y-4 shadow-sm">

      <div className="flex items-center justify-between">

        <div>

          <div className="text-sm text-gray-500">Task ID</div>

          <div className="font-mono text-sm">{task.id}</div>

        </div>

        <div className={`text-sm font-medium capitalize ${getStatusColor(task.status)}`}>

          {task.status}

        </div>

      </div>

      {guidance ? (

        <div className="border rounded-lg p-3 bg-gray-50 space-y-3">

          <div className="flex items-center gap-2">

            <span className={`px-2 py-1 text-xs rounded ${getBadgeColor(guidance.classification)}`}>

              {guidance.classification || 'evidence'}

            </span>

            <span className="text-xs text-gray-400">read-only execution evidence</span>

          </div>

          {(guidance.outcome || evidence.outcomePreview) && (

            <div className="text-sm text-gray-800 font-medium">

              {guidance.outcome || evidence.outcomePreview}

            </div>

          )}

          {(guidance.explanation || evidence.explanationPreview) && (

            <details className="text-sm text-gray-600">

              <summary className="cursor-pointer hover:underline">

                View explanation

              </summary>

              <div className="mt-2 whitespace-pre-wrap">

                {guidance.explanation || evidence.explanationPreview}

              </div>

            </details>

          )}

          <details className="text-sm text-gray-600" open>

            <summary className="cursor-pointer hover:underline">

              View execution evidence

            </summary>

            <div className="mt-3 rounded-lg border bg-white p-3 space-y-2">

              <EvidenceRow label="run_id" value={evidence.runId} />

              <EvidenceRow label="task_id" value={evidence.taskId} />

              <EvidenceRow label="actor" value={evidence.actor} />

              <EvidenceRow label="source" value={evidence.source} />

              <EvidenceRow label="completed_at" value={evidence.completedAt} />

              <EvidenceRow label="updated_at" value={evidence.updatedAt} />

              <EvidenceRow

                label="trace_visibility"

                value={evidence.systemTrace?.visibility}

              />

              <EvidenceRow

                label="trace_purpose"

                value={evidence.systemTrace?.purpose}

              />

            </div>

          </details>

          {evidence.systemTrace?.content && (

            <details className="text-sm text-gray-600">

              <summary className="cursor-pointer hover:underline">

                View system trace payload

              </summary>

              <pre className="mt-2 max-h-56 overflow-auto rounded-lg border bg-white p-3 text-xs">

                {JSON.stringify(evidence.systemTrace.content, null, 2)}

              </pre>

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

