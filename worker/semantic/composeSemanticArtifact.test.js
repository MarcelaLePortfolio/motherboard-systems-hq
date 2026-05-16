
const { composeSemanticArtifact } = require('./composeSemanticArtifact');

const samples = [

  'Create a luxury visual launch card for Moonrise Bakery customers',

  'Summarize the latest execution results',

  'Create a checklist for artifact validation',

  'Generate an executive dashboard for internal operations'

];

for (const sample of samples) {

  console.log('\\nINPUT:');

  console.log(sample);

  console.log('\\nOUTPUT:');

  console.log(JSON.stringify(composeSemanticArtifact(sample), null, 2));

}

