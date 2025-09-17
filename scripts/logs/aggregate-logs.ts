import fs from 'fs';
import path from 'path';

const logFiles = ['logs/cade-out.log', 'logs/effie-out.log', 'logs/matilda-out.log'];

logFiles.forEach(file => {
  if (fs.existsSync(file)) {
    const content = fs.readFileSync(file, 'utf-8');
    console.log(`📂 Contents of ${file}:\n${content}`);
  }
});
