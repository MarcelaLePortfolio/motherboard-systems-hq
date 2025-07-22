import { effieCommandRouter } from '../../../src/scripts/agents/effie';

async function run() {
  console.log('💻 Effie is online. Waiting for instructions...');
  process.stdin.setEncoding('utf-8');

  for await (const chunk of process.stdin) {
    try {
      const input = JSON.parse(chunk);
      const { command, args } = input;
      const result = await effieCommandRouter(command, args);
      console.log(JSON.stringify(result));
    } catch (err: any) {
      console.error(`❌ Effie failed: ${err.message}`);
    }
  }
}

run();
