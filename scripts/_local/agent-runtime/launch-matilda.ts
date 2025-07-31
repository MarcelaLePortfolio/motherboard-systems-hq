import fs from "fs";

// ✅ Emit agent-online event for authentic status
fs.appendFileSync(
  "ui/dashboard/ticker-events.log",
  `{"timestamp":"${Math.floor(Date.now()/1000)}","agent":"matilda","event":"agent-online"}\n`
);
console.log("<0001f7e2> Matilda ticker event emitted: agent-online");

// Keep process alive for PM2 visibility
setInterval(() => {}, 60000);
