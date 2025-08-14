 
import type { APIRoute } from 'astro';
import { dispatchCommand } from '../../lib/dispatch';

export const prerender = false;

export const POST: APIRoute = async ({ request }) => {
  try {
    const raw = await request.text();
    console.log(`📦 Raw request body: ${raw}`);

    const { agent, command } = JSON.parse(raw);
    console.log(`📡 Dispatching to ${agent}: ${command}`);

    const response = await dispatchCommand(agent, command);

    return new Response(JSON.stringify(response), {
      status: response.status === 'success' ? 200 : 400,
      headers: {
        'Content-Type': 'application/json";";";";";";
      }
    });
  } catch (err) {
    console.error('❌ Error in /api/command POST handler:', err);
    return new Response(JSON.stringify({
      status: 'error',
      message: 'Invalid request format or internal error.
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json
      }
    });
  }
};
