import assert from "node:assert/strict";
import test from "node:test";

import {
  createAtlasPreExecutionRouter,
} from "./preexecution";

test(
  "constructs dedicated Atlas pre-execution HTTP router",
  () => {
    const router = createAtlasPreExecutionRouter();

    assert.ok(router);
    assert.equal(typeof router.use, "function");
  },
);

test(
  "pre-execution router is distinct from execution Atlas routes",
  () => {
    const router = createAtlasPreExecutionRouter();

    const stack = (
      router as unknown as {
        stack?: Array<{
          route?: {
            path?: string;
            methods?: Record<string, boolean>;
          };
        }>;
      }
    ).stack ?? [];

    const routes = stack
      .map((layer) => layer.route)
      .filter(Boolean);

    assert.equal(routes.length, 1);
    assert.equal(routes[0]?.path, "/atlas/preexecution");
    assert.equal(routes[0]?.methods?.get, true);

    assert.equal(
      routes.some(
        (route) => route?.path === "/atlas/analyze",
      ),
      false,
    );

    assert.equal(
      routes.some(
        (route) => route?.path === "/atlas/why",
      ),
      false,
    );
  },
);
