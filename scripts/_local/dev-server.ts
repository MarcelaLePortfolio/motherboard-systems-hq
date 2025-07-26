import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
const port = 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dashboardPath = path.join(__dirname, "../../ui/dashboard");
app.use(express.static(dashboardPath)); // serves styles.css, dash.js, favicon.ico, index.html by default

app.listen(port, () => {
  console.log(`<0001f9ff> Favicon + all dashboard assets now served from root`);
});
