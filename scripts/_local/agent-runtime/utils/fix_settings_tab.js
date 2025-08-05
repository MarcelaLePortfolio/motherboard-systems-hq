import fs from 'fs';
const filePath = 'ui/dashboard/index.html';
let html = fs.readFileSync(filePath, 'utf-8');

// Replace the entire settings-tab content
const snippet = `
  <div class="agent-controls">
    <h4>Cade</h4>
    <button id="cade-start">Start Cade</button>
    <button id="cade-stop">Stop Cade</button>
    <button id="cade-restart">Restart Cade</button>
  </div>
  <div class="agent-controls">
    <h4>Matilda</h4>
    <button id="matilda-start">Start Matilda</button>
    <button id="matilda-stop">Stop Matilda</button>
    <button id="matilda-restart">Restart Matilda</button>
  </div>
  <div class="agent-controls">
    <h4>Effie</h4>
    <button id="effie-start">Start Effie</button>
    <button id="effie-stop">Stop Effie</button>
    <button id="effie-restart">Restart Effie</button>
  </div>
  <!-- Cade auto-injected buttons -->
`;

html = html.replace(
  /<div class="tab-content" id="settings-tab">[\s\S]*?<\/div>/,
  `<div class="tab-content" id="settings-tab">${snippet}\n    </div>`
);

fs.writeFileSync(filePath, html, 'utf-8');
console.log("✅ Multi-agent Start/Stop/Restart panel injected successfully.");
