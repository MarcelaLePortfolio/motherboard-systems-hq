import fs from 'fs';
import path from 'path';
import { runOllamaInference } from '../../_local/utils/ollamaClient';

export async function refactorCodeWithOllama(opts: { file: string; outputPath?: string }) {
  const { file, outputPath } = opts;
  const safePath = path.resolve(file);
  const content = fs.readFileSync(safePath, 'utf-8');

  const prompt = [
    'You are a TypeScript expert.',
    'Refactor the following code to improve readability, modularity, and performance.',
    'Avoid changing behavior. Use modern best practices.',
    '',
    'Respond ONLY with the refactored code block.',
    '',
    '```ts',
    content,
    '```'
  ].join('\\n');

  const refactored = await runOllamaInference(prompt);

  if (outputPath) {
    const safeOutput = path.resolve(outputPath);
    fs.mkdirSync(path.dirname(safeOutput), { recursive: true });
    fs.writeFileSync(safeOutput, refactored, 'utf-8');
    return { status: 'success', refactoredPath: safeOutput };
  }

  return { status: 'success', refactored };
}
