import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
const port = 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dashboardPath = path.join(__dirname, "../../ui/dashboard");
app.use("/", express.static(dashboardPath)); // Serves index.html, styles.css, dash.js, and favicon.ico from root

app.listen(port, () => {
  console.log(`<0001f9ff> ✅ Dashboard + favicon now correctly served from http://localhost:${port}/`);
});
