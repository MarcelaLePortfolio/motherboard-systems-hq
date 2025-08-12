import { handleInstallTask } from "./install";
import { handleCommitTask } from "./commit";

export async function routeTask(task: any): Promise<string> {
  const type = task?.type;

  switch (type) {
    case "install":
      return await handleInstallTask(task.package);
    case "commit":
      return await handleCommitTask(task.message || "🤖 Cade auto-commit");
    default:
      return `⚠️ Unknown task type: "${type}"`;
  }
}
