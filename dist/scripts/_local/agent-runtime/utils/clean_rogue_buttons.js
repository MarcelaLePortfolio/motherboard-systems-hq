import fs from 'fs';
const filePath = 'ui/dashboard/index.html';
let html = fs.readFileSync(filePath, 'utf-8');
// 1️⃣ Keep only content up to the first <!-- Cade auto-injected buttons --> block
const firstPanelMatch = html.match(/[\s\S]*?<!-- Cade auto-injected buttons -->/);
if (firstPanelMatch) {
    html = firstPanelMatch[0] + '\n    </div>\n  </div>\n</body>\n</html>';
}
// 2️⃣ Write the cleaned file
fs.writeFileSync(filePath, html, 'utf-8');
console.log("✅ Cleaned file: removed rogue duplicates and kept single control panel.");
