import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
const port = 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const dashboardPath = path.resolve(__dirname, "../../ui/dashboard");

// Serve everything in ui/dashboard at root
app.use(express.static(dashboardPath));

app.listen(port, () => {
  console.log(`✅ Minimal static server running at http://localhost:${port}/`);
  console.log(`➡  Test: /agent-status.json should return JSON`);
});
