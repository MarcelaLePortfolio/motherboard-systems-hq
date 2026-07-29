import React from 'react';
import { useMissionControl } from '../mission-control/useMissionControl';

/**
 * MissionDashboardWorkspace
 * Reads the authoritative governance timeline and renders each stage.
 * The most-recent stage is highlighted; if no timeline exists, show a placeholder.
 */
export default function MissionDashboardWorkspace() {
  const { timeline } = useMissionControl();               // authoritative data

  const stages = React.useMemo(() => {
    if (!timeline?.length) return [];
    const ordered: string[] = [];
    timeline.forEach(({ stage }: { stage: string }) => {
      if (stage && !ordered.includes(stage)) ordered.push(stage);
    });
    return ordered;
  }, [timeline]);

  if (!stages.length) {
    return (
      <div className="p-4 text-sm text-gray-500">
        No mission in progress.
      </div>
    );
  }

  const currentStage = stages[stages.length - 1];

  return (
    <div className="flex flex-col gap-2">
      {stages.map((stage) => (
        <div
          key={stage}
          className={`rounded px-3 py-2 border transition-colors ${
            stage === currentStage
              ? 'border-blue-500 bg-blue-50 font-semibold'
              : 'border-gray-200 bg-white'
          }`}
        >
          {stage}
        </div>
      ))}
    </div>
  );
}
