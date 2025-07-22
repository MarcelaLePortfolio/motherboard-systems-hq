import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request }) => {
  try {
    const { agent, command } = await request.json();

    console.log(`📡 Received command for ${agent}: ${command}`);

    return new Response(JSON.stringify({
      status: 'success',
      received: { agent, command }
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  } catch (err) {
    console.error('❌ Error in /api/command POST handler:', err);
    return new Response(JSON.stringify({
      status: 'error',
      message: 'Invalid request format or internal error.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
};
