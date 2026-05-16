
const { generateVisualMetadata } = require('./generateVisualMetadata');

const samples = [

  'Create a luxury launch card for Moonrise Bakery',

  'Generate an executive dashboard for internal operations',

  'Make a playful kids event flyer',

  'Create a stakeholder briefing visual'

];

for (const sample of samples) {

  console.log('');

  console.log('INPUT:');

  console.log(sample);

  console.log('');

  console.log('OUTPUT:');

  console.log(JSON.stringify(generateVisualMetadata(sample), null, 2));

}

