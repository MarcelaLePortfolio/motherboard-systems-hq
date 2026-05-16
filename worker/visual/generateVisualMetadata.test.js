
const { generateVisualMetadata } = require('./generateVisualMetadata');

const samples = [

  'Create a luxury launch card for Moonrise Bakery',

  'Generate an executive dashboard for internal operations',

  'Make a playful kids event flyer',

  'Create a stakeholder briefing visual'

];

for (const sample of samples) {

  console.log('\\nINPUT:');

  console.log(sample);

  console.log('\\nOUTPUT:');

  console.log(JSON.stringify(generateVisualMetadata(sample), null, 2));

}

