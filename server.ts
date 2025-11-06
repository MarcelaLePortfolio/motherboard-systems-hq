// <0001faf7> Phase 9.6 — Dashboard Server Rebind + Static Public Serve
import express from "express";
import path from "path";
import cors from "cors";

const app = express();
app.use(cors());

// Serve the dashboard and other static assets
const publicPath = path.join(process.cwd(), "public");
app.use(express.static(publicPath));

// Default route → dashboard.html
app.get("/", (_req, res) => {
  res.sendFile(path.join(publicPath, "dashboard.html"));
});

// Bind on 3001
const PORT = 3001;
app.listen(PORT, () => {
  console.log(`🖥️  Dashboard server running at http://localhost:${PORT}`);
});
