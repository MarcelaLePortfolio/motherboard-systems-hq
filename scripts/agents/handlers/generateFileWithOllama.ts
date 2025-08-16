import fs from 'fs';
import path from 'path';
import { runOllamaInference } from '../../_local/utils/ollamaClient';

export async function generateFileWithOllama(args: { prompt: string; outputPath: string }) {
  const { prompt, outputPath } = args;
  const content = await runOllamaInference(prompt);
  fs.writeFileSync(path.resolve(outputPath), content, 'utf8');
  return { status: 'success', generatedPath: path.resolve(outputPath) };
}
