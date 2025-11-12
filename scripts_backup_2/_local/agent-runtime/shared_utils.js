const fs = require('fs');
const path = require('path');

const TICKER_LOG = path.resolve('memory/ticker.log');
const STATUS_FILE = path.resolve('memory/agent_status.json');

function logEvent(agent, event) {
  const entry = JSON.stringify({
    timestamp: Math.floor(Date.now() / 1000),
    agent,
    event
  });
  fs.appendFileSync(TICKER_LOG, entry + '\n');
}

function setStatus(agent, status) {
  let data = {};
  try {
    data = JSON.parse(fs.readFileSync(STATUS_FILE, 'utf8'));
  } catch {
    // fallback to empty object
  }
  data[agent] = { status, ts: Math.floor(Date.now() / 1000) };
  fs.writeFileSync(STATUS_FILE, JSON.stringify(data, null, 2));
}

module.exports = {
  logEvent,
  setStatus
};
