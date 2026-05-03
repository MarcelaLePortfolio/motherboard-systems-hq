import router from "./systemHealth";

type JsonBody = Record<string, unknown>;

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function findGetHandler() {
  const stack = (router as unknown as { stack?: Array<{ route?: { path?: string; methods?: Record<string, boolean>; stack?: Array<{ handle: Function }> } }> }).stack;

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

async function runSmoke(): Promise<string> {
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

  assert(!!jsonBody, "Route did not return JSON payload");
  assert(jsonBody?.status === "OK", "Unexpected status");
  assert(typeof jsonBody?.uptime === "number", "Unexpected uptime");
  assert(typeof jsonBody?.memory === "object", "Unexpected memory payload");
  assert(typeof jsonBody?.timestamp === "string", "Unexpected timestamp");
  assert(
    jsonBody?.situationSummary ===
      "SYSTEM STABLE\n" +
        "NO EXECUTION RISK DETECTED\n" +
        "COGNITION SIGNALS CONSISTENT\n" +
        "SIGNALS COHERENT\n" +
        "NO OPERATOR ACTION REQUIRED",
    "Unexpected situationSummary"
  );

  return "PASS";
}

runSmoke().then((result) => {
  if (result !== "PASS") {
    throw new Error("System health route smoke failed");
  }
});
