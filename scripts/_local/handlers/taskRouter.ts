import { handleInstallTask } from "./install";
import { handleCommitTask } from "./commit";
import { handleBuildUITask } from "./buildUI";

export async function routeTask(task: any): Promise<string> {
  const type = task?.type;

  switch (type) {
    case "install":
      return await handleInstallTask(task.package);
    case "commit":
      return await handleCommitTask(task.message || "🤖 Cade auto-commit");
    case "build-ui":
      // Optional: task.command can override default "pnpm run build"
      return await handleBuildUITask(task.command);
    default:
      return `⚠️ Unknown task type: "${type}"`;
  }
}
