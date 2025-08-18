import { cadeCommandRouter } from '../../scripts/handlers/cade_router';

async function runTests() {
  const testFile = 'scripts/test_generated/hello.ts';

  // Generate a file
  console.log(await cadeCommandRouter('generate', { path: 'scripts/test_generated/generated.ts', type: 'hello world script' }));

  // Summarize
  console.log(await cadeCommandRouter('summarize', { path: testFile }));

  // Explain
  console.log(await cadeCommandRouter('explain', { path: testFile }));

  // Comment
  console.log(await cadeCommandRouter('comment', { path: testFile }));

  // Format comments
  console.log(await cadeCommandRouter('format', { path: testFile }));

  // Refactor
  console.log(await cadeCommandRouter('refactor', { path: testFile }));

  // Translate
  console.log(await cadeCommandRouter('translate', { path: testFile }));

  // Convert
  console.log(await cadeCommandRouter('convert', { path: testFile }));
}

runTests();
