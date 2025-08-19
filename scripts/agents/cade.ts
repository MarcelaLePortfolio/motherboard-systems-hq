// scripts/agents/cade.ts
import { cadeCommandRouter } from '../_local/agent-runtime/cadeCommandRouter';

const [command, ...restArgs] = process.argv.slice(2);

(async () => {
  try {
    const parsedArgs = restArgs.length === 1
      ? restArgs[0]
      : restArgs;

    const result = await cadeCommandRouter(command, parsedArgs);
    console.log('<0001f9e0> Cade Response:\n', JSON.stringify(result, null, 2));
  } catch (err) {
    console.error('❌ Cade failed:', err);
  }
})();
