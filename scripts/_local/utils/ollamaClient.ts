/**
 * Ollama HTTP client
 * - Uses env vars:
 *    OLLAMA_BASE_URL (default: http://localhost:11434)
 *    OLLAMA_MODEL (default: llama3.1)
 */

type GenerateRequest = {
  model: string;
  prompt: string;
  stream?: boolean;
  options?: Record<string, unknown>;
};

type GenerateResponse = {
  response?: string;
  done?: boolean;
  error?: string;
};

const OLLAMA_BASE_URL = process.env.OLLAMA_BASE_URL || 'http://localhost:11434';
const OLLAMA_MODEL = process.env.OLLAMA_MODEL || 'llama3.1';

export async function runOllamaInference(prompt: string, opts: { model?: string } = {}): Promise<string> {
  const url = `${OLLAMA_BASE_URL.replace(/\/$/, '')}/api/generate`;
  const body: GenerateRequest = {
    model: opts.model || OLLAMA_MODEL,
    prompt,
    stream: false
  };

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });

  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(`Ollama request failed: ${res.status} ${res.statusText} ${text ? `- ${text.slice(0,200)}` : ''}`);
  }

  const data = (await res.json()) as GenerateResponse;
  if (data.error) throw new Error(`Ollama error: ${data.error}`);
  return (data.response || '').trim();
}
