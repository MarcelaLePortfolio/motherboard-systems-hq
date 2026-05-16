
const { prepareArtifactSemanticMetadata } = require('./prepareArtifactSemanticMetadata');

const samples = [

  'Create a luxury visual launch card for Moonrise Bakery customers',

  'Summarize the latest execution results',

  '',

  null

];

for (const sample of samples) {

  console.log('');

  console.log('INPUT:');

  console.log(sample);

  console.log('');

  console.log('METADATA:');

  console.log(JSON.stringify(prepareArtifactSemanticMetadata(sample), null, 2));

}

