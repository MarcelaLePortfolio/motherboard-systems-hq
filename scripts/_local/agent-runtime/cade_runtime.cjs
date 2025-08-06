const path = require('path');
const fs = require('fs');
const log = console.log;  // or your logging function
const writeResume = (data) => {
  const resumePath = path.join(__dirname, '../../../memory/agent_chain_resume.json');
  fs.writeFileSync(resumePath, JSON.stringify(data, null, 2));
};
