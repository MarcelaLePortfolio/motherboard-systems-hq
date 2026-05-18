
const { extractSections } = require('./extractSections');

const samples = [

  '# Summary\nSystem is stable.\n\n## Next Steps\nContinue safely.',

  'Context:\nRuntime stable.\n\nDecision:\nProceed with read-only extraction.',

  'Plain artifact with no explicit sections.'

];

for (const sample of samples) {

  console.log('');

  console.log('INPUT:');

  console.log(sample);

  console.log('');

  console.log('SECTIONS:');

  console.log(JSON.stringify(extractSections(sample), null, 2));

}

