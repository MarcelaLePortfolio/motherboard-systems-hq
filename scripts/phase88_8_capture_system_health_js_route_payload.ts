import router from "../routes/diagnostics/systemHealth.js";

type JsonBody = Record<string, unknown>;

function findGetHandler() {
  const stack = (
    router as unknown as {
      stack?: Array<{
        route?: {
          path?: string;
          methods?: Record<string, boolean>;
          stack?: Array<{ handle: Function }>;
        };
      }>;
    }
  ).stack;

  if (!stack) {
    throw new Error("Router stack missing");
  }

  for (const layer of stack) {
    if (
      layer.route?.path === "/" &&
      layer.route.methods?.get === true &&
      layer.route.stack &&
      layer.route.stack.length > 0
    ) {
      return layer.route.stack[0].handle;
    }
  }

  throw new Error("GET / handler not found");
}

async function main(): Promise<void> {
  const handler = findGetHandler();

  let jsonBody: JsonBody | undefined;

  const req = {};
  const res = {
    json(payload: JsonBody) {
      jsonBody = payload;
      return payload;
    },
  };

  await handler(req, res);

  if (!jsonBody) {
    throw new Error("Route did not return JSON payload");
  }

  process.stdout.write(JSON.stringify(jsonBody, null, 2) + "\n");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
