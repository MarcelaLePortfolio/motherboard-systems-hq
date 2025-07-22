import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request }) => {
  const { agent, command } = await request.json();

  console.log(`📡 Received command: ${command} from agent: ${agent}`);

  // Simulate handling logic
  return new Response(JSON.stringify({
    status: 'received',
    agent,
    command
  }), {
    status: 200,
    headers: {
      'Content-Type': 'application/json'
    }
  });
};
