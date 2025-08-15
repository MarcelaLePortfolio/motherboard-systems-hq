import { IncomingMessage, ServerResponse } from 'http';
import { matildaCommandRouter } from '../../scripts/agents/matilda';

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  if (req.method !== 'POST') {
    res.writeHead(405);
    res.end('Method Not Allowed');
    return;
  }

  try {
    const chunks: Uint8Array[] = [];
    for await (const chunk of req) chunks.push(chunk);
    const { command, payload } = JSON.parse(Buffer.concat(chunks).toString());

    const result = await matildaCommandRouter(command, payload || {});
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(result));
  } catch (err: any) {
    res.writeHead(500);
    res.end(JSON.stringify({ status: 'error', message: err.message || err }));
  }
}
