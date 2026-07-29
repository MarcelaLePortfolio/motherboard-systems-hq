import { useEffect, type ReactNode } from "react";
import type { MissionPresentationModel } from "../mission-control/missionPresentationMapper";
import type { MissionTimelineEntry } from "../mission-control/missionReadApi";
import { useMissionControl } from "../mission-control/useMissionControl";

const ACTIVE_PACKAGE_ID = "corridor-smoke";

interface MissionCardProps {
  title: string;
  children: ReactNode;
  className?: string;
}

function MissionCard({
  title,
  children,
  className = "",
}: MissionCardProps) {
  return (
    <section
      className={`rounded-xl border border-gray-200 bg-white p-4 shadow-sm ${className}`}
    >
      <h2 className="mb-3 text-xs font-semibold uppercase tracking-wide text-gray-500">
        {title}
      </h2>
      {children}
    </section>
  );
}

function formatLabel(value: string | null | undefined): string {
  if (!value) {
    return "Unavailable";
  }

  return value
    .replace(/[_-]+/g, " ")
    .toLowerCase()
    .replace(/\b\w/g, (character) => character.toUpperCase());
}

function formatTimestamp(value: string | null | undefined): string {
  if (!value) {
    return "Timestamp unavailable";
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return date.toLocaleString();
}

function getTimelineStage(entry: MissionTimelineEntry): string | null {
  const stage = entry.stage ?? entry.event_type;

  return typeof stage === "string" && stage.trim()
    ? stage.trim()
    : null;
}

function CurrentMissionCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  return (
    <MissionCard title="Current Mission" className="lg:col-span-2">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <p className="text-xl font-semibold text-gray-950">
            {mission.packageId}
          </p>
          <p className="mt-2 text-sm text-gray-600">
            Authoritative governance mission supplied by Mission Read.
          </p>
        </div>

        <span className="w-fit rounded-full border border-gray-200 bg-gray-50 px-3 py-1 text-xs font-medium text-gray-700">
          Version {mission.version}
        </span>
      </div>
    </MissionCard>
  );
}

function MissionStatusCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  return (
    <MissionCard title="Mission Status">
      <p className="text-lg font-semibold text-gray-950">
        {formatLabel(mission.stage)}
      </p>

      <p className="mt-2 text-sm text-gray-600">
        Health: {formatLabel(mission.health)}
      </p>
    </MissionCard>
  );
}

function GovernanceLifecycleCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  if (!mission.timeline.length) {
    return (
      <MissionCard title="Governance Lifecycle" className="lg:col-span-2">
        <p className="text-sm text-gray-500">
          No lifecycle activity recorded.
        </p>
      </MissionCard>
    );
  }

  const currentIndex = mission.timeline.length - 1;

  return (
    <MissionCard title="Governance Lifecycle" className="lg:col-span-2">
      <ol className="space-y-3">
        {mission.timeline.map((entry, index) => {
          const stage = getTimelineStage(entry) ?? `Event ${index + 1}`;
          const isCurrent = index === currentIndex;

          return (
            <li
              key={`${stage}-${entry.timestamp ?? index}`}
              className={`rounded-lg border px-3 py-3 ${
                isCurrent
                  ? "border-blue-400 bg-blue-50"
                  : "border-gray-200 bg-gray-50"
              }`}
            >
              <p
                className={`text-sm font-semibold ${
                  isCurrent ? "text-blue-800" : "text-gray-900"
                }`}
              >
                {formatLabel(stage)}
              </p>

              <p className="mt-1 text-xs text-gray-500">
                {formatTimestamp(entry.timestamp)}
              </p>
            </li>
          );
        })}
      </ol>
    </MissionCard>
  );
}

function LatestEventCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  const latestEntry = mission.timeline[mission.timeline.length - 1];
  const latestStage = latestEntry
    ? getTimelineStage(latestEntry)
    : null;

  return (
    <MissionCard title="Latest Event">
      <p className="text-lg font-semibold text-gray-950">
        {latestStage ? formatLabel(latestStage) : "No event recorded"}
      </p>

      <p className="mt-2 text-sm text-gray-500">
        {formatTimestamp(
          latestEntry?.timestamp ?? mission.latestTimestamp,
        )}
      </p>
    </MissionCard>
  );
}

function NextStepCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  return (
    <MissionCard title="Next Step">
      <p className="text-lg font-semibold text-gray-950">
        {mission.awaiting
          ? formatLabel(mission.awaiting)
          : "No authoritative next step reported"}
      </p>

      <p className="mt-2 text-sm text-gray-500">
        Execution and assignment remain outside this presentation corridor.
      </p>
    </MissionCard>
  );
}

function PackageDetailsCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  return (
    <MissionCard title="Package Details" className="lg:col-span-2">
      <dl className="grid gap-4 sm:grid-cols-2">
        <div>
          <dt className="text-xs uppercase tracking-wide text-gray-500">
            Package ID
          </dt>
          <dd className="mt-1 break-all text-sm font-medium text-gray-900">
            {mission.packageId}
          </dd>
        </div>

        <div>
          <dt className="text-xs uppercase tracking-wide text-gray-500">
            Project
          </dt>
          <dd className="mt-1 text-sm font-medium text-gray-900">
            {mission.projectId ?? "Unavailable"}
          </dd>
        </div>

        <div>
          <dt className="text-xs uppercase tracking-wide text-gray-500">
            Lifecycle Events
          </dt>
          <dd className="mt-1 text-sm font-medium text-gray-900">
            {mission.lifecycleEventCount}
          </dd>
        </div>

        <div>
          <dt className="text-xs uppercase tracking-wide text-gray-500">
            Integrity Warnings
          </dt>
          <dd className="mt-1 text-sm font-medium text-gray-900">
            {mission.integrityWarnings.length}
          </dd>
        </div>
      </dl>
    </MissionCard>
  );
}

function ActiveAgentCard({
  mission,
}: {
  mission: MissionPresentationModel;
}) {
  const hasAuthoritativeOwner =
    mission.owner && mission.owner.toUpperCase() !== "UNKNOWN";

  return (
    <MissionCard title="Active Agent">
      <p className="text-lg font-semibold text-gray-950">
        {hasAuthoritativeOwner
          ? formatLabel(mission.owner)
          : "Not Assigned"}
      </p>

      <p className="mt-2 text-sm text-gray-500">
        {hasAuthoritativeOwner
          ? "Reported by Mission Read."
          : "Assignment runtime is not yet available."}
      </p>
    </MissionCard>
  );
}

export default function MissionDashboardWorkspace() {
  const {
    mission,
    status,
    error,
    loadMission,
    refresh,
  } = useMissionControl();

  useEffect(() => {
    void loadMission(ACTIVE_PACKAGE_ID);
  }, [loadMission]);

  if (status === "idle" || status === "loading") {
    return (
      <div className="p-6 text-sm text-gray-500">
        Loading authoritative mission state…
      </div>
    );
  }

  if (status === "not_found") {
    return (
      <div className="p-6 text-sm text-gray-500">
        No mission in progress.
      </div>
    );
  }

  if (status === "error" || !mission) {
    return (
      <div className="p-6">
        <p className="text-sm text-red-700">
          {error ?? "Mission Control could not load the mission."}
        </p>

        <button
          type="button"
          onClick={() => void refresh()}
          className="mt-4 rounded border border-gray-300 px-3 py-2 text-sm font-medium text-gray-800"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <main className="min-h-full bg-gray-50 p-4 sm:p-6">
      <header className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">
            Mission Control
          </p>

          <h1 className="mt-1 text-2xl font-semibold text-gray-950">
            {mission.packageId}
          </h1>
        </div>

        <button
          type="button"
          onClick={() => void refresh()}
          className="w-fit rounded border border-gray-300 bg-white px-3 py-2 text-sm font-medium text-gray-800 shadow-sm"
        >
          Refresh mission
        </button>
      </header>

      <div className="grid gap-4 lg:grid-cols-3">
        <CurrentMissionCard mission={mission} />
        <MissionStatusCard mission={mission} />

        <GovernanceLifecycleCard mission={mission} />

        <div className="grid gap-4">
          <LatestEventCard mission={mission} />
          <NextStepCard mission={mission} />
        </div>

        <PackageDetailsCard mission={mission} />
        <ActiveAgentCard mission={mission} />
      </div>
    </main>
  );
}
