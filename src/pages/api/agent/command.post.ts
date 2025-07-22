import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request }) => {
  const { agent, command } = await request.json();

  // Placeholder logic — replace with real routing
  let mockResponse = '';
  switch (agent) {
    case 'matilda':
      mockResponse = `Matilda received: "${command}"`;
      break;
    case 'cade':
      mockResponse = `Cade is processing: "${command}"`;
      break;
    case 'effie':
      mockResponse = `Effie is executing: "${command}"`;
      break;
    default:
      mockResponse = `Unknown agent "${agent}"`;
  }

  return new Response(
    JSON.stringify({ response: mockResponse }),
    { status: 200, headers: { 'Content-Type': 'application/json' } }
  );
};
