/**
 * Gizmo Engine Shim — temporary runtime bridge for Cade, Matilda, Effie.
 * In production, this delegates to the real internal engine embedded in training.
 */

export function runAgent(agent: any, opts: { local: boolean; env: string }) {
  console.log(`🚀 [Gizmo Shim] Launching agent: ${agent?.name || "unknown"} in ${opts.env} mode (local=${opts.local})`);
  if (agent?.run) {
    agent.run();
  } else {
    console.log("⚠️ No .run() method found on agent — placeholder shim active.");
  }
}
