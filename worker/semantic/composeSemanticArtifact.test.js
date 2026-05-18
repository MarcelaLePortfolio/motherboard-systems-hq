
const { composeSemanticArtifact } = require('./composeSemanticArtifact');

const samples = [

  'Create a luxury visual launch card for Moonrise Bakery customers',

  'Summarize the latest execution results',

  'Create a checklist for artifact validation',

  'Generate an executive dashboard for internal operations',

  '# Summary\nSystem is stable.\n\n## Next Steps\nContinue safely.'

];

for (const sample of samples) {

  console.log('');

  console.log('INPUT:');

  console.log(sample);

  console.log('');

  console.log('OUTPUT:');

  console.log(JSON.stringify(composeSemanticArtifact(sample), null, 2));

}

