import fs from 'fs';
import path from 'path';
import { runOllamaInference } from '../../_local/utils/ollamaClient';

export async function commentCodeWithOllama(args: {
  file: string;
  outputPath?: string;
}) {
  const { file, outputPath } = args;
  const resolvedPath = path.resolve(file);
  const code = fs.readFileSync(resolvedPath, 'utf8');

  const prompt = `Add helpful comments to the following TypeScript code:\n\n${code}`;
  const commented = await runOllamaInference(prompt);

  const outPath = outputPath || resolvedPath.replace(/\.ts$/, '-commented.ts');
  fs.writeFileSync(outPath, commented, 'utf8');

  return { status: 'success', commentedPath: outPath };
}
