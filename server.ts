import express from "express";
import path from "path";

// 🧠 Core App
const app = express();
app.use(express.json());

// ✅ Primary Dynamic Endpoints (your existing routes can stay here)
// Example:
// app.post("/matilda", async (req, res) => {
//   const { message } = req.body;
//   // handle message routing...
//   res.json({ ok: true });
// });

// ✅ Static Dashboard Serving
if (process.argv[1] && process.argv[1].includes("server.ts")) {
  const publicDir = path.join(process.cwd(), "public");
  app.use(express.static(publicDir));
  console.log(`📦 Static files served from ${publicDir}`);

  const PORT = process.env.PORT || 3001;
  app.listen(PORT, () => {
    console.log(`🚀 Express server running at http://localhost:${PORT}`);
  });
}

// 🪛 Optional: Redirect /dashboard → /dashboard.html
app.get("/dashboard", (req, res) => {
  res.redirect("/dashboard.html");
});

// <0001fa9c> Optional: Redirect root → /dashboard.html
app.get("/", (req, res) => {
  res.redirect("/dashboard.html");
});
