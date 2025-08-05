import fs from 'fs';
import path from 'path';

const tickerLogPath = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');

// Track last event to prevent duplicates
let lastEventKey = '';

export function logTickerEvent(event) {
  if (!event || !event.agent || !event.event) return;

  // Skip chat events entirely
  const isChat = event.type === 'chat' || event.event.includes('chat');
  if (isChat) return;

  const humanMessage = `💚 ${event.agent} ${event.event.replace('-', ' ')}`;
  const eventKey = `${event.agent}-${event.event}`;

  // Skip duplicate consecutive events
  if (eventKey === lastEventKey) return;
  lastEventKey = eventKey;

  fs.appendFileSync(tickerLogPath, humanMessage + '\n');
}

// Initialize ticker with startup line
fs.writeFileSync(tickerLogPath, '💻 Dashboard initialized\n');
