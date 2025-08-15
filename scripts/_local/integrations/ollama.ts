export async function callOllama(prompt: string): Promise<string> {
  console.log(`[OLLAMA] Simulating call with prompt: "${prompt}"`);
  // Simulated response
  return `🔮 Ollama response to: "${prompt}"`;
}
