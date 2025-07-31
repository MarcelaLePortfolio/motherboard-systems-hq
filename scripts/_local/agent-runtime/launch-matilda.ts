import fs from "fs";

function emitOnline() {
  const ts = Math.floor(Date.now() / 1000);
  const event = `{"timestamp":"${ts}","agent":"matilda","event":"agent-online"}\n`;
  fs.appendFileSync("ui/dashboard/ticker-events.log", event);
  console.log("💚 Matilda ticker event emitted: agent-online");
}

// Emit immediately and every 60 seconds
emitOnline();
setInterval(emitOnline, 60000);

// Keep process alive for PM2
setInterval(() => {}, 60000);
