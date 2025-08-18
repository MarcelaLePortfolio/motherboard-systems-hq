import { cadeCommandRouter } from "../handlers/cade_router";

export async function handleTask(task: any) {
  const { command, args } = task;

  switch (command) {
    case "chain": {
      const steps = [
        { command: "generate", args: { type: "README" } },
        { command: "commit", args: { message: "📄 Initial scaffold commit" } },
      ];

      const results = [];

      for (const step of steps) {
        console.log(`🔁 Running step: ${step.command}`);
        const result = await cadeCommandRouter(step.command, step.args);
        results.push({ step: step.command, result });

        if (result.status !== "success") {
          console.log(`❌ Step failed: ${step.command}`);
          break;
        }
      }

      return { status: "completed", results };
    }

    default:
      return { status: "error", message: `Unknown command: ${command}` };
  }
}
