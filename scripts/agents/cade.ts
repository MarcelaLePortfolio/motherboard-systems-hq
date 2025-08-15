import fs from 'fs';
import path from 'path';
import { runOllamaInference } from '../_local/utils/ollamaClient';

/**
 * Cade Command Router
 * Commands:
 *  - echo { message }
 *  - list files { dir? }
 *  - read file { path }
 *  - write to file { path, content }
 *  - summarize { file, maxChunkSize?, outputPath? }
 *  - explain { file, outputPath? }
 *  - comment { file, outputPath? }
 */
export async function cadeCommandRouter(command: string, args: any = {}) {
  try {
    switch (command) {
      case 'echo':
        return { status: 'success', message: args.message || '' };

      case 'list files': {
        const targetDir = args.dir || '.';
        const resolvedDir = path.resolve(targetDir);
        const files = fs.readdirSync(resolvedDir);
        return { status: 'success', files: files.sort() };
      }

      case 'read file': {
        const safePath = validateSafePath(args.path);
        const content = fs.readFileSync(safePath, 'utf-8');
        return { status: 'success', content };
      }

      case 'write to file': {
        const safePath = validateSafePath(args.path);
        ensureDir(path.dirname(safePath));
        fs.writeFileSync(safePath, args.content ?? '', 'utf-8');
        return { status: 'success', path: safePath };
      }

      case 'summarize': {
        const { file, maxChunkSize = 8000, outputPath } = args || {};
        const safePath = validateSafePath(file);
        const content = fs.readFileSync(safePath, 'utf-8');

        const chunks = chunkText(content, maxChunkSize);
        const partials: string[] = [];
        let index = 0;
        for (const chunk of chunks) {
          index += 1;
          const partPrompt = [
            'You are a precise code/doc summarizer.',
            'Summarize the following content clearly and concisely.',
            'Focus on: purpose, key components/sections, noteworthy details, and any TODOs/risks.',
            '',
            `# Chunk ${index}/${chunks.length}`,
            '```',
            chunk,
            '```',
            '',
            'Return a tight bullet summary (5–12 bullets).'
          ].join('\n');
          const partial = await runOllamaInference(partPrompt);
          partials.push(`## Chunk ${index}\n${partial}`);
        }

        const reducePrompt = [
          'Synthesize a cohesive summary from the chunk summaries below.',
          'Keep it structured:',
          '1) One-paragraph overview',
          '2) Key points (bullets)',
          '3) Risks/TODOs (bullets, optional)',
          '',
          'Chunk Summaries:',
          partials.join('\n\n---\n\n')
        ].join('\n');

        const summary = await runOllamaInference(reducePrompt);

        if (outputPath) {
          const safeOutput = validateSafePath(outputPath, { allowNonexistent: true, mustBeWithinCwd: true });
          ensureDir(path.dirname(safeOutput));
          fs.writeFileSync(safeOutput, summary, 'utf-8');
          return { status: 'success', summaryPath: safeOutput, chunks: chunks.length };
        }

        return { status: 'success', summary, chunks: chunks.length };
      }

      case 'explain': {
        const { file, outputPath } = args || {};
        const safePath = validateSafePath(file);
        const content = fs.readFileSync(safePath, 'utf-8');

        const prompt = [
          'You are a technical explainer. Your task is to explain the following code in plain English.',
          'Do not summarize — explain.',
          '',
          'Explain:',
          '1) The structure of the file',
          '2) Purpose of each major part',
          '3) What the code *actually does*',
          '',
          'Return a detailed and beginner-friendly walkthrough. Include code references where helpful.',
          '',
          '```ts',
          content,
          '```'
        ].join('\n');

        const explanation = await runOllamaInference(prompt);

        if (outputPath) {
          const safeOutput = validateSafePath(outputPath, { allowNonexistent: true, mustBeWithinCwd: true });
          ensureDir(path.dirname(safeOutput));
          fs.writeFileSync(safeOutput, explanation, 'utf-8');
          return { status: 'success', explanationPath: safeOutput };
        }

        return { status: 'success', explanation };
      }

      case 'comment': {
        const { file, outputPath } = args || {};
        const safePath = validateSafePath(file);
        const content = fs.readFileSync(safePath, 'utf-8');

        const prompt = [
          'You are a helpful TypeScript code assistant.',
          'Insert inline comments throughout this file to explain:',
          '- Function purposes',
          '- Non-obvious logic',
          '- Assumptions or caveats',
          '',
          'Avoid over-commenting trivial things.',
          'Format output as valid commented TypeScript. Preserve original code structure.',
          '',
          '```ts',
          content,
          '```'
        ].join('\n');

        const commentedCode = await runOllamaInference(prompt);

        if (outputPath) {
          const safeOutput = validateSafePath(outputPath, { allowNonexistent: true, mustBeWithinCwd: true });
          ensureDir(path.dirname(safeOutput));
          fs.writeFileSync(safeOutput, commentedCode, 'utf-8');
          return { status: 'success', commentedPath: safeOutput };
        }

        return { status: 'success', commented: commentedCode };
      }

      default:
        return { status: 'error', message: `Unknown command: ${command}` };
    }
  } catch (err: any) {
    return { status: 'error', message: err.message || String(err) };
  }
}

function validateSafePath(inputPath: string, opts: { allowNonexistent?: boolean; mustBeWithinCwd?: boolean } = {}) {
  if (!inputPath || typeof inputPath !== 'string') throw new Error('No file path provided.');
  const resolved = path.resolve(inputPath);
  const cwd = process.cwd();

  if (opts.mustBeWithinCwd !== false) {
    if (!resolved.startsWith(cwd + path.sep) && resolved !== cwd) {
      throw new Error('Unsafe file path.');
    }
  }

  if (!opts.allowNonexistent) {
    if (!fs.existsSync(resolved)) throw new Error('File does not exist.');
    const stat = fs.statSync(resolved);
    if (!stat.isFile()) throw new Error('Path is not a file.');
  }

  return resolved;
}

function ensureDir(dirPath: string) {
  if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });
}

function chunkText(text: string, maxChars: number): string[] {
  if (text.length <= maxChars) return [text];
  const parts: string[] = [];
  let i = 0;
  while (i < text.length) {
    parts.push(text.slice(i, i + maxChars));
    i += maxChars;
  }
  return parts;
}
