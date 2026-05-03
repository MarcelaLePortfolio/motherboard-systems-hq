/**
 * STEP 1 — FIRST-CALL LATENCY ISOLATION
 * Instrumentation only — no system mutations.
 */

const TARGET = "http://localhost:8080/api/chat";

async function runProbe(label) {
  const start = Date.now();

  console.log(`\n=== ${label} ===`);
  console.log(`request_start: ${start}`);

  const beforeFetch = Date.now();

  const res = await fetch(TARGET, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: "probe: latency check",
    }),
  });

  const afterFetch = Date.now();

  const jsonStart = Date.now();
  const data = await res.json();
  const jsonEnd = Date.now();

  const reply = data.reply ?? data.response ?? data.message ?? "";

  console.log(`request_sent: ${beforeFetch}`);
  console.log(`response_received: ${afterFetch}`);
  console.log(`json_parse_start: ${jsonStart}`);
  console.log(`json_parse_end: ${jsonEnd}`);
  console.log(`response_complete: ${Date.now()}`);

  console.log("\n--- DELTAS ---");
  console.log(`network_time: ${afterFetch - beforeFetch}ms`);
  console.log(`json_parse_time: ${jsonEnd - jsonStart}ms`);
  console.log(`total_time: ${Date.now() - start}ms`);

  console.log("\n--- RESPONSE SNAPSHOT ---");
  console.log({
    status: res.status,
    ok: res.ok,
    hasReply: reply.length > 0,
    length: reply.length,
  });
}

async function main() {
  console.log("MATILDA FIRST-CALL LATENCY PROBE");

  await runProbe("FIRST CALL");
  await new Promise((r) => setTimeout(r, 2000));

  await runProbe("SECOND CALL");
  await new Promise((r) => setTimeout(r, 2000));

  await runProbe("THIRD CALL");
}

main().catch((err) => {
  console.error("Probe failed:", err);
  process.exit(1);
});
