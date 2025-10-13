/* eslint-disable import/no-commonjs */
#!/usr/bin/env node

// Dashboard Ticker Log Reader (Lightweight Endpoint)
// Serves latest 50 ticker events as JSON array
// Usage: node ui/dashboard/api/ticker.js

const fs = require('fs');
const http = require('http');
const path = require('path');
const LOG_PATH = path.join(__dirname, '..', 'ticker-events.log');

http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');
  try {
    const data = fs.readFileSync(LOG_PATH, 'utf-8')
      .trim()
      .split(
')
      .filter(Boolean)
      .slice(-50)
      .map(line => JSON.parse(line));
    res.writeHead(200);
    res.end(JSON.stringify(data));
  } catch (err) {
    res.writeHead(500);
    res.end(JSON.stringify({ error: 'Failed to read ticker log', details: err.message }));
  }
}).listen(3080, () => {
  console.log('📡 Ticker log reader running on http://localhost:3080');
});
