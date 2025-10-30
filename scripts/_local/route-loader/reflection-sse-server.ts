// <0001fad9> Phase 4.7-lite — External Reflection SSE Server Loader
import express from "express";
import { reflectionsSSE, broadcastReflections } from "../../streams/reflection-sse-lite.js";
import chokidar from "chokidar";
import path from "path";

const app = express();
const dbPath = path.join(process.cwd(), "db", "main.db");

app.get("/events/reflections", reflectionsSSE);

app.listen(3101, () => {
  console.log("<0001f7e2> Reflection SSE stream active at http://localhost:3101/events/reflections");
});

// watch db for changes and push new reflections
const watcher = chokidar.watch([dbPath, dbPath + "-wal", dbPath + "-shm"], {
  persistent: true,
  ignoreInitial: true,
});
watcher.on("change", () => broadcastReflections());
