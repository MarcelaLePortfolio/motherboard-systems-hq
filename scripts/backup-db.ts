import fs from 'fs';
import path from 'path';

const dbFile = path.resolve('motherboard.db');
const backupFile = path.resolve(`motherboard.db.bak`);

fs.copyFileSync(dbFile, backupFile);
console.log(`✅ Backup created: ${backupFile}`);
