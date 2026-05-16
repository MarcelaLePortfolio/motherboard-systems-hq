
/**

 * Phase 726 semantic pipeline inspector.

 *

 * Runs classifier, composer, and validator together.

 * Inspect-only.

 * No runtime wiring.

 */

const { composeSemanticArtifact } = require('./composeSemanticArtifact');

const { validateSemanticArtifact } = require('./validateSemanticArtifact');

const samples = [

  'Create a luxury visual launch card for Moonrise Bakery customers',

  'Summarize the latest execution results',

  'Create a checklist for artifact validation',

  'Generate an executive dashboard for internal operations',

  'Create a stakeholder briefing visual'

];

let failures = 0;

for (const sample of samples) {

  const payload = composeSemanticArtifact(sample);

  const validation = validateSemanticArtifact(payload);

  console.log('');

  console.log('────────────────────────────────');

  console.log('INPUT:');

  console.log(sample);

  console.log('');

  console.log('COMPOSED PAYLOAD:');

  console.log(JSON.stringify(payload, null, 2));

  console.log('');

  console.log('VALIDATION:');

  console.log(JSON.stringify(validation, null, 2));

  if (!validation.valid) {

    failures += 1;

  }

}

console.log('');

console.log('────────────────────────────────');

if (failures > 0) {

  console.error(`Semantic pipeline inspection failed with ${failures} invalid payload(s).`);

  process.exit(1);

}

console.log('Semantic pipeline inspection passed.');

