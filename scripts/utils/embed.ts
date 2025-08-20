// scripts/utils/embed.ts
import fetch from 'node-fetch';

export async function embed(prompt: string, model = 'nomic-embed-text') {
  const res = await fetch('http://localhost:11434/api/embeddings', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ model, prompt }),
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Ollama embed failed: ${res.status} – ${errorText}`);
  }

  const json = await res.json();
  return { embedding: json.embedding };
}
