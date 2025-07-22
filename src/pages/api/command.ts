import type { APIRoute } from 'astro';

export const prerender = false;

export const POST: APIRoute = async ({ request }) => {
  try {
    const raw = await request.text();
    console.log(`📦 Raw request body: ${raw}`);

    const { agent, command } = JSON.parse(raw);

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
