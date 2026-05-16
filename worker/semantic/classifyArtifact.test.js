
const { classifyArtifact } = require('./classifyArtifact');

const samples = [

  'Create a visual launch card for Moonrise Bakery',

  'Summarize the latest execution results',

  'Create a checklist for artifact validation',

  'Build a plan for preview-aware Matilda refinement'

];

for (const sample of samples) {

  console.log(JSON.stringify(classifyArtifact(sample), null, 2));

}

