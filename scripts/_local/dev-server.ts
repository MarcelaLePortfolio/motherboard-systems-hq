import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
const port = 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dashboardPath = path.join(__dirname, "../../ui/dashboard");
app.use("/ui/dashboard", express.static(dashboardPath));
app.use("/styles.css", express.static(path.join(dashboardPath, "styles.css")));
app.use("/dash.js", express.static(path.join(dashboardPath, "dash.js")));
app.use("/agent-status.json", express.static(path.join(dashboardPath, "agent-status.json")));

app.get("/", (_, res) => {
  res.sendFile(path.join(dashboardPath, "index.html"));
});

app.listen(port, () => {
  console.log(`<0001f9fd> Server live at http://localhost:${port}/`);
});
