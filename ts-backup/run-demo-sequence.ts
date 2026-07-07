// <0001fad9> Phase 6.0 — Demo Scenario Assembly
console.log("🧩 Forcing SQLite path → db/main.db");

export async function runDemoSequence() {
  console.log("🎬 Starting Demo Sequence...");
  try {
    sqlite.prepare("DELETE FROM reflection_index").run();
    sqlite.prepare("DELETE FROM task_events").run();

    const reflections = [
      "Matilda initialized demo mode.",
      "Cade verifying task queue...",
      "Effie confirming backup integrity.",
      "Matilda broadcasting cycle status.",
      "Demo sequence complete — OPS stable."
    ];
    reflections.forEach(r =>
      sqlite.prepare("INSERT INTO reflection_index (content) VALUES (?)").run(r)
    );

    const tasks = [
      "Initialize system environment",
      "Check SQLite schema",
      "Verify broadcast connections",
      "Simulate reflection updates"
    ];
    tasks.forEach(t =>
      sqlite.prepare("INSERT INTO task_events (description, status) VALUES (?, 'completed')").run(t)
    );

    console.log("✅ Demo data injected successfully!");
    console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
  } catch (err) {
    console.error("❌ Demo sequence failed:", err);
  }
}

if (process.argv[1].includes("run-demo-sequence.ts")) {
  runDemoSequence();
}
