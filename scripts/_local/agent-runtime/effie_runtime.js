#!/usr/bin/env node
import fs from 'fs';
import path from 'path';

const STATUS_FILE = path.resolve('memory/agent_status.json');
const TICKER_LOG = path.resolve('memory/ticker.log');

// --- Utility functions ---
function logEvent(agent, event) {
  const entry = JSON.stringify({ timestamp: Math.floor(Date.now()/1000), agent, event });
  fs.appendFileSync(TICKER_LOG, entry + "\n");
}

function setStatus(status) {
  let data = {};
  try { data = JSON.parse(fs.readFileSync(STATUS_FILE,'utf8')); } catch {}
  data.effie = { status, lastHeartbeat: Math.floor(Date.now()/1000) };
  fs.writeFileSync(STATUS_FILE, JSON.stringify(data,null,2));
}

function heartbeat() { setStatus('online'); }

function shutdown() {
  logEvent('effie', '❌ Effie offline');
  setStatus('offline');
  process.exit();
}
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

// --- Initial Online State ---
logEvent('effie', '💚 Effie online');
setStatus('online');
setInterval(heartbeat, 5000);

// --- Effie main loop placeholder ---
console.log("🤖 Effie Runtime Started — Ready for tasks!");
