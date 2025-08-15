// ...previous cadeCommandRouter content remains unchanged above this point...

      case 'comment': {
        // Comment a file using Ollama Inference
        const { file, outputPath } = args || {};
        const safePath = validateSafePath(file);
        const content = fs.readFileSync(safePath, 'utf-8');

        const prompt = [
          'You are a helpful TypeScript code assistant.',
          'Your task: insert inline comments *neatly* throughout this code.',
          '',
          '🧠 Commenting instructions:',
          '- Explain function purposes, tricky logic, and assumptions',
          '- Use `// === SECTION ===` headers for major areas (e.g., Utilities, Router)',
          '- Keep spacing readable — do not clutter every line',
          '- Keep all output valid TypeScript',
          '',
          'Avoid over-commenting trivial code like basic assignments or string splits.',
          '',
          'Return only the final commented code.',
          '',
          '```ts',
          content,
          '```'
        ].join('\n');

        const commentedCode = await runOllamaInference(prompt);

        // If an output path is provided, write the commented code to a file
        if (outputPath) {
          const safeOutput = validateSafePath(outputPath, { allowNonexistent: true, mustBeWithinCwd: true });
          ensureDir(path.dirname(safeOutput));
          fs.writeFileSync(safeOutput, commentedCode, 'utf-8');
          return { status: 'success', commentedPath: safeOutput };
        }

        // Return the final commented code
        return { status: 'success', commented: commentedCode };
      }

// ...everything else unchanged below this point...
