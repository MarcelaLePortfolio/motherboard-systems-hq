export default async function chainHandler(options) {
  // options.steps: array of commands/tasks
  const steps = options?.steps || [];
  const results = [];

  for (const step of steps) {
    // Each step can be a string describing an action for Cade
    try {
      const result = await import("./cade.js").then(m => m.cadeCommandRouter(step.action, step.options));
      results.push({ step, result });
    } catch (err) {
      results.push({ step, error: err.message });
    }
  }

  return { status: "chain complete", results };
}
