#!/usr/bin/env node
// =========================================
// Authentic Agent Status Endpoint
// =========================================
// Reads ticker-events.log and reports online/offline for Cade, Effie, Matilda
// Agent is considered online if last "agent-online" event < 3 min ago
// =========================================

const fs = require('fs');
const http = require('http');
const path = require('path');

const LOG_PATH = path.join(__dirname, '..', 'ticker-events.log');
const PORT = 3081; // different from ticker endpoint

function getAgentStatus() {
  const now = Math.floor(Date.now() / 1000);
  const cutoff = 3 * 60; // 3 minutes
  const agents = { cade: 'offline', effie: 'offline', matilda: 'offline' };

  try {
    const data = fs.readFileSync(LOG_PATH, 'utf-8')
      .trim()
      .split('\n')
      .filter(Boolean)
      .map(line => JSON.parse(line));

    // Reverse iterate to find last online event per agent
    for (let i = data.length - 1; i >= 0; i--) {
      const ev = data[i];
      if (agents[ev.agent] === 'offline' && ev.event === 'agent-online') {
        if ((now - ev.timestamp) < cutoff) {
          agents[ev.agent] = 'online';
        }
      }
      // stop if all found
      if (Object.values(agents).every(v => v !== 'offline')) break;
    }

  } catch (err) {
    console.error("❌ Failed to read ticker log:", err.message);
  }

  return { ...agents, timestamp: now };
}

http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');
  res.writeHead(200);
  res.end(JSON.stringify(getAgentStatus(), null, 2));
}).listen(PORT, () => {
  console.log(`📡 Agent status endpoint running on http://localhost:${PORT}`);
});
