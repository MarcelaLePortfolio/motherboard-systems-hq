import fs from 'fs';
import path from 'path';
import { runOllamaInference } from '../../_local/utils/ollamaClient';

export async function explainCodeWithOllama(args: { file: string }) {
  const code = fs.readFileSync(path.resolve(args.file), 'utf8');
  const prompt = `Explain the following code:\n\n${code}`;
  const explanation = await runOllamaInference(prompt);
  return { status: 'success', explanation };
}