import { startAgentWithPM2 } from './handlers/startAgentWithPM2';
import { installDepsWithCade } from "./handlers/installDepsWithCade";

export async function cadeCommandRouter(command: string, payload?: any) {
  switch (command) {
    case "install dependencies":
      return await installDepsWithCade(payload);
    default:
      return { status: "error", message: "Unknown command." };
  }
}
