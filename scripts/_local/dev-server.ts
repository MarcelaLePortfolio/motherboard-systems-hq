import express from "express";
import path from "path";

const app = express();
const port = 3000;

const dashboardPath = path.join(__dirname, "../../ui/dashboard");
app.use("/ui/dashboard", express.static(dashboardPath));

app.get("/", (_, res) => {
  res.send(`<h1>✅ Dev server running.</h1><p>Go to <a href="/ui/dashboard/">/ui/dashboard/</a></p>`);
});

app.listen(port, () => {
  console.log(`🟢 Server live at http://localhost:${port}/ui/dashboard/`);
});
