import fs from 'fs';
import path from 'path';
import { runOllamaInference } from '../../_local/utils/ollamaClient';

export async function formatCommentsWithOllama(args: { file: string }) {
  const code = fs.readFileSync(path.resolve(args.file), 'utf8');
  const prompt = `Improve the inline comments in the following code:\n\n${code}`;
  const formatted = await runOllamaInference(prompt);
  return { status: 'success', formatted };
}
