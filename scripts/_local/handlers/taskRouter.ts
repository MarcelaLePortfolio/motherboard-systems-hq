import { handleInstallTask } from "./install";

export async function routeTask(task: any): Promise<string> {
  const type = task?.type;

  switch (type) {
    case "install":
      return await handleInstallTask(task.package);
    default:
      return `⚠️ Unknown task type: "${type}"`;
  }
}
