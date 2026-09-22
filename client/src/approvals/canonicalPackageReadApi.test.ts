import assert from "node:assert/strict";
import test from "node:test";

import {
  fetchCanonicalPackages,
} from "./canonicalPackageReadApi";

test("fetchCanonicalPackages encodes project_id", async () => {
  const originalFetch = globalThis.fetch;
  let requestedUrl = "";

  globalThis.fetch = async (
    input: RequestInfo | URL,
  ) => {
    requestedUrl = String(input);

    return new Response(
      JSON.stringify({
        project_id: "hq project",
        packages: [],
      }),
      {
        status: 200,
        headers: {
          "content-type": "application/json",
        },
      },
    );
  };

  try {
    const result =
      await fetchCanonicalPackages("hq project");

    assert.equal(
      requestedUrl,
      "/api/canonical-packages?project_id=hq%20project",
    );
    assert.deepEqual(result.packages, []);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("fetchCanonicalPackages fails closed on non-ok response", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = async () =>
    new Response("failure", {
      status: 500,
    });

  try {
    await assert.rejects(
      () => fetchCanonicalPackages("hq"),
      /Unable to load approved Canonical Packages/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
