import { routeToEffie } from "@/agents/effie/index";
import { routeToCade } from "@/agents/cade/index";

export async function ask(task: string): Promise<string> {
  const lower = task.toLowerCase();

  if (
    lower.includes("screenshot") ||
    lower.includes("rename") ||
    lower.includes("move") ||
    lower.includes("open") ||
    lower.includes("file") ||
    lower.includes("finder") ||
    lower.includes("desktop")
  ) {
    return await routeToEffie(task);
  }

  if (
    lower.includes("deploy") ||
    lower.includes("server") ||
    lower.includes("restart") ||
    lower.includes("vercel") ||
    lower.includes("tunnel") ||
    lower.includes("pm2")
  ) {
    return await routeToCade(task);
  }

  return `<0001f9e0> Matilda received: "${task}" — but isn't sure how to route it yet.`;
}
