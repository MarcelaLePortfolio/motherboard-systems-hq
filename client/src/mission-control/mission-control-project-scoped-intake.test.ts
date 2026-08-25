import assert from "node:assert/strict";
import test from "node:test";

import {
  getMissionReadModel,
  MissionReadNotFoundError,
  MissionReadRequestError,
} from "./missionReadApi";

test("Mission Read client requests the project-scoped endpoint", async () => {
  const originalFetch = globalThis.fetch;
  let requestedUrl = "";

  globalThis.fetch = async (input) => {
    requestedUrl = String(input);

    return new Response(
      JSON.stringify({
        ok: true,
        mission: {
          identity: {
            package_id: "pkg-1",
            package_version: 1,
            project_id: "hq",
          },
          requested_outcome: "Outcome",
          stage: "INTERPRETATION",
          owner: "UNKNOWN",
          health: "UNKNOWN",
          awaiting: null,
          evidence: {
            artifact_count: 0,
            lifecycle_event_count: 0,
            integrity_warnings: [],
            latest_timestamp: null,
          },
          timeline: [],
        },
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  };

  try {
    const mission = await getMissionReadModel("hq");

    assert.equal(requestedUrl, "/api/mission-read/hq");
    assert.equal(mission.identity.project_id, "hq");
    assert.equal(mission.identity.package_id, "pkg-1");
    assert.equal(mission.identity.package_version, 1);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("Mission Read client rejects an empty project id", async () => {
  await assert.rejects(
    () => getMissionReadModel("   "),
    (error: unknown) =>
      error instanceof MissionReadRequestError &&
      error.status === 400,
  );
});

test("404 represents no active operational mission", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        ok: false,
        error: "No active operational mission for project.",
      }),
      {
        status: 404,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );

  try {
    await assert.rejects(
      () => getMissionReadModel("hq"),
      (error: unknown) =>
        error instanceof MissionReadNotFoundError &&
        error.projectId === "hq",
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("409 fails closed as a Mission Read request error", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        ok: false,
        error: "Operational mission identity mismatch.",
      }),
      {
        status: 409,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );

  try {
    await assert.rejects(
      () => getMissionReadModel("hq"),
      (error: unknown) =>
        error instanceof MissionReadRequestError &&
        error.status === 409,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
