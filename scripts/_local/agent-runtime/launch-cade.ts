import fs from "fs";

fs.appendFileSync(
  "ui/dashboard/ticker-events.log",
  `{"timestamp":"${Math.floor(Date.now()/1000)}","agent":"cade","event":"agent-online"}\n`
);
console.log("🟢 Cade ticker event emitted: agent-online");

// Keep process alive so PM2 shows online
setInterval(() => {}, 60000);
