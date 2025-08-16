import fs from 'fs';
import path from 'path';
import { runOllamaInference } from '../../_local/utils/ollamaClient';

export async function translateCommentsWithOllama(args: {
  file: string;
  language: string;
  outputPath?: string;
}) {
  const { file, language, outputPath } = args;

  if (!file || !language) {
    throw new Error('Missing required args: file and language');
  }

  const content = fs.readFileSync(file, 'utf-8');

  const prompt = [
    `You are a professional technical translator.`,
    `Translate the following TypeScript code into ${language}.`,
    '',
    'Respond ONLY with the translated code block:',
    '```ts',
    content,
    '```'
  ].join('\n');

  const translated = await runOllamaInference(prompt);

  if (outputPath) {
    const safeOutput = path.resolve(outputPath);
    fs.mkdirSync(path.dirname(safeOutput), { recursive: true });
    fs.writeFileSync(safeOutput, translated, 'utf-8');
    return { status: 'success', translatedPath: safeOutput };
  }

  return { status: 'success', translated };
}