import { runGuidanceEngine } from './guidance-engine.js';

export async function buildGuidance(context) {
  const result = await runGuidanceEngine({
    tasks: context.tasks || [],
    failures: context.failures || [],
    retries: context.retries || []
  });

  console.log('GUIDANCE_ENGINE_RESULT:', JSON.stringify(result, null, 2));

  return {
    guidance_available: !!result && result.items && result.items.length > 0,
    items: result.items || [],
    meta: result.meta || {}
  };
}
