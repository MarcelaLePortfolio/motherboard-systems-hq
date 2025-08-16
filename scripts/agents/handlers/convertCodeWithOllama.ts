import fs from 'fs';
import path from 'path';
import { runOllamaInference } from '../../_local/utils/ollamaClient';

export async function convertCodeWithOllama(args: {
  file: string;
  language: string;
  outputPath?: string;
}) {
  const { file, language, outputPath } = args;

  if (!file || !language) {
    throw new Error('Missing required parameters: file and language.');
  }

  const safePath = path.resolve(file);
  const content = fs.readFileSync(safePath, 'utf-8');

  const prompt = [
    `Convert the following code to ${language}.`,
    'Be accurate and preserve functionality.',
    '',
    '```ts',
    content,
    '```'
  ].join('\n');

  const converted = await runOllamaInference(prompt);

  if (outputPath) {
    const safeOutput = path.resolve(outputPath);
    fs.mkdirSync(path.dirname(safeOutput), { recursive: true });
    fs.writeFileSync(safeOutput, converted, 'utf-8');
    return { status: 'success', convertedPath: safeOutput };
  }

  return { status: 'success', converted };
}
