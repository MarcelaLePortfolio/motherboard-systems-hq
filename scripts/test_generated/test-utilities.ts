import { cadeCommandRouter } from '../../scripts/handlers/cade_router';

async function runSystemUtilityTests() {
  const testFile = 'scripts/test_generated/hello.ts';

  console.log('--- Install Dependencies ---');
  console.log(await cadeCommandRouter('installDeps', { packages: ['typescript', 'tsx'] }));

  console.log('--- Run Script/Command ---');
  console.log(await cadeCommandRouter('runScript', { command: 'echo "Hello World"' }));

  console.log('--- Start Agent with PM2 ---');
  console.log(await cadeCommandRouter('startAgent', { agentName: 'effie' }));

  console.log('--- Report Status ---');
  console.log(await cadeCommandRouter('reportStatus'));

  console.log('--- Create Backup ---');
  console.log(await cadeCommandRouter('createBackup'));

  console.log('--- Run Test Files ---');
  console.log(await cadeCommandRouter('runTests'));

  // Optionally, include Ollama handlers to verify integration
  console.log('--- Generate ---');
  console.log(await cadeCommandRouter('generate', { path: 'scripts/test_generated/generated.ts', type: 'hello world script' }));

  console.log('--- Summarize ---');
  console.log(await cadeCommandRouter('summarize', { path: testFile }));

  console.log('--- Explain ---');
  console.log(await cadeCommandRouter('explain', { path: testFile }));

  console.log('--- Comment ---');
  console.log(await cadeCommandRouter('comment', { path: testFile }));

  console.log('--- Format Comments ---');
  console.log(await cadeCommandRouter('format', { path: testFile }));

  console.log('--- Refactor ---');
  console.log(await cadeCommandRouter('refactor', { path: testFile }));

  console.log('--- Translate ---');
  console.log(await cadeCommandRouter('translate', { path: testFile }));

  console.log('--- Convert ---');
  console.log(await cadeCommandRouter('convert', { path: testFile }));
}

runSystemUtilityTests();
