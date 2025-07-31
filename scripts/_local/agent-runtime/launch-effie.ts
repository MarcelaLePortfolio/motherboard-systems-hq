import fs from "fs";

fs.appendFileSync(
  "ui/dashboard/ticker-events.log",
  `{"timestamp":"${Math.floor(Date.now()/1000)}","agent":"effie","event":"agent-online"}\n`
);
console.log("🟢 Effie ticker event emitted: agent-online");

// Keep process alive so PM2 shows online
setInterval(() => {}, 60000);
