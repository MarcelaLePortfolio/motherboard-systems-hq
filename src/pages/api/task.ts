import type { APIRoute } from 'astro';
import { exec } from 'child_process';

export const POST: APIRoute = async ({ request }) => {
  try {
    const { task } = await request.json();

    if (!task || typeof task !== 'string') {
      return new Response('❌ Invalid task input', { status: 400 });
    }

    const result = await new Promise<string>((resolve, reject) => {
      exec(task, { timeout: 10000 }, (err, stdout, stderr) => {
        if (err) {
          reject(stderr || err.message);
        } else {
          resolve(stdout || '✅ Done');
        }
      });
    });

    return new Response(result, { status: 200 });
  } catch (err: any) {
    return new Response(`❌ ${err.message || err}`, { status: 500 });
  }
};
