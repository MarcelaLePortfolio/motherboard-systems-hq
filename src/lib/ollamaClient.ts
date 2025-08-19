import http from 'http';
import https from 'https';
import { URL } from 'url';

type EmbedRequest = {
  model: string;
  input: string[];
};

type EmbedResponse = {
  embeddings: number[][];
};

export class OllamaClient {
  private base: string;
  constructor(base = 'http://127.0.0.1:11434') {
    this.base = base.replace(/\/+$/, '');
  }

  async embed(req: EmbedRequest): Promise<number[][]> {
    const url = new URL('/api/embeddings', this.base);
    const body = JSON.stringify({ model: req.model, input: req.input });
    const isHttps = url.protocol === 'https:';
    const lib = isHttps ? https : http;

    const payload: number[][] = await new Promise((resolve, reject) => {
      const request = lib.request(
        {
          method: 'POST',
          hostname: url.hostname,
          path: url.pathname,
          port: url.port || (isHttps ? 443 : 80),
          headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(body),
          },
        },
        (res) => {
          const chunks: Buffer[] = [];
          res.on('data', (d) => chunks.push(d));
          res.on('end', () => {
            const txt = Buffer.concat(chunks).toString('utf8');
            try {
              const parsed = JSON.parse(txt) as EmbedResponse;
              if (!parsed.embeddings || !Array.isArray(parsed.embeddings)) {
                return reject(new Error('Invalid embeddings response'));
              }
              resolve(parsed.embeddings);
            } catch (e) {
              reject(e);
            }
          });
        }
      );
      request.on('error', reject);
      request.write(body);
      request.end();
    });

    return payload;
  }
}
