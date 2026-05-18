
const { classifyArtifact } = require('./classifyArtifact');

const samples = [

  'Create a visual launch card for Moonrise Bakery',

  'Summarize the latest execution results',

  'Create a checklist for artifact validation',

  'Build a plan for preview-aware Matilda refinement',

  'Create a preview card for launch',

  'Create a preview-aware advisory refinement plan'

];

for (const sample of samples) {

  console.log(JSON.stringify(classifyArtifact(sample), null, 2));

}

