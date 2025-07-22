import { askBrain } from "./utils/askBrain";

export async function routeToEffie(task: string): Promise<string> {
  try {
    const result = await askBrain(task);
    return `🖥️ Effie’s output:\n\${result}`;
  } catch (err: any) {
    return `❌ Effie error: \${err.message || err}`;
  }
}
