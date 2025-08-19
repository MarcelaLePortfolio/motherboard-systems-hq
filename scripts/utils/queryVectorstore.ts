export async function queryVectorstore(namespace: string, prompt: string) {
  return {
    status: 'ok',
    message: `🧠 Queried namespace "${namespace}" with prompt: "${prompt}" (stub response)`,
  };
}
