
const { composeSemanticArtifact } = require('./composeSemanticArtifact');

const { validateSemanticArtifact } = require('./validateSemanticArtifact');

const samples = [

  'Create a luxury visual launch card for Moonrise Bakery customers',

  'Summarize the latest execution results',

  'Create a checklist for artifact validation',

  'Generate an executive dashboard for internal operations'

];

let failures = 0;

for (const sample of samples) {

  const payload = composeSemanticArtifact(sample);

  const result = validateSemanticArtifact(payload);

  console.log('\\nINPUT:');

  console.log(sample);

  console.log('\\nVALIDATION:');

  console.log(JSON.stringify(result, null, 2));

  if (!result.valid) {

    failures += 1;

  }

}

if (failures > 0) {

  process.exit(1);

}

