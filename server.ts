import express from "express";
import path from "path";

const app = express();
app.use(express.json());

// 🧠 Dynamic Endpoints Placeholder (add Matilda, Cade, Effie later)

// ✅ Static Dashboard Serving
app.get("/", (req, res) => res.redirect("/dashboard.html"));
app.get("/dashboard", (req, res) => res.redirect("/dashboard.html"));

const publicDir = path.join(process.cwd(), "public");
app.use(express.static(publicDir));
console.log(`📦 Static files served from ${publicDir}`);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Express server running at http://localhost:${PORT}`);
});

// <0001fa9f> Diagnostic Routes (temporary placeholder responses)
app.get("/insight/persist", (req, res) => {
  res.json([{ title: "Insight A", detail: "System successfully reinitialized." }]);
});

app.get("/cognitive/history", (req, res) => {
  res.json([{ coherence: 0.92, reflections: 18, timestamp: new Date().toISOString() }]);
});

app.get("/system/health", (req, res) => {
  res.json({ audits: 12, insights: 5, reflections: 3, lessons: 2 });
});

app.get("/introspect/history", (req, res) => {
  res.json([{ id: 1, success: 85, risk: 15 }]);
});

app.get("/adaptation/history", (req, res) => {
  res.json([{ action: "Interval Adjust", value: "30s", timestamp: new Date().toISOString() }]);
});

app.get("/visual/trends", (req, res) => {
  res.json([{ t: 1, success: 80, risk: 20 }, { t: 2, success: 82, risk: 18 }]);
});

app.get("/adaptation/verify", (req, res) => {
  res.json({ interval: "30s", next: new Date(Date.now() + 30000).toISOString(), status: "Stable" });
});

app.get("/chronicle/list", (req, res) => {
  res.json([
    { timestamp: new Date().toISOString(), event: "System restarted and diagnostic dashboard online." }
  ]);
});
