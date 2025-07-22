import type { APIRoute } from "astro";
import { askRouter } from "../../../agents/matilda/askRouter";

export const POST: APIRoute = async ({ request }) => {
  const { task } = await request.json();
  const output = await askRouter(task);
  return new Response(output);
};
