export default async function chainHandler(options) {
  const steps = options?.steps || [];
  const results = [];

  for (const step of steps) {
    try {
      // Dynamically import cadeCommandRouter for each step
      const result = await import("./cade.js").then(m =>
        m.cadeCommandRouter(step.action, step.options)
      );
      results.push({ step, result });
    } catch (err) {
      results.push({ step, error: err.message });
    }
  }

  return { status: "chain complete", results };
}
