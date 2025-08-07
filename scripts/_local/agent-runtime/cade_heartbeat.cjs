const fs = require('fs');
const path = require('path');
const logFile = path.join(__dirname, '../../memory/cade_heartbeat.log');
fs.appendFileSync(logFile, `[${new Date().toISOString()}] 💓 Cade heartbeat\n`);
