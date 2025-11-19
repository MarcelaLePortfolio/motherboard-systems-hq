import { handleInstallTask } from "./install.js";
export async function routeTask(task) {
    const type = task?.type;
    switch (type) {
        case "install":
            return await handleInstallTask(task.package);
        default:
            return "⚠️ Unknown task type: \"" + type + "\"";
    }
}
