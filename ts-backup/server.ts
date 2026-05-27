// <0001fb61> Phase 10.2 — Root Redirect + SSE Verification
import express from "express";
import path from "path";

const app = express();
const PORT = process.env.PORT || 3000;

// ✅ Root redirect for demo
app.get("/", (_req, res) => {
  res.redirect("/dashboard.html");
});

// Serve public assets
app.use(express.static(path.join(process.cwd(), "public")));

// Health check endpoint for PM2 / curl tests
app.get("/health", (_req, res) => {
  res.status(200).json({ ok: true, message: "Server healthy." });
});

// Fallback 404
app.use((_req, res) => {
  res.status(404).send("404: Not Found");
});

app.listen(PORT, () => {
  console.log(`✅ Demo server running at http://localhost:${PORT}`);
});
