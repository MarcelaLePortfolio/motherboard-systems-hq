// <0001fbB1> dashboardRoutes – matches the beige HTML layout
import express from "express";
const router = express.Router();

router.get("/dashboard", (_req, res) => {
  res.send(`
    <html>
      <head><title>Motherboard Systems Dashboard</title></head>
      <body style="font-family: sans-serif; background: #f4f0e6; color: #333;">
        <h1>🚀 Motherboard Systems HQ Dashboard</h1>
        <p>Server is running and API routes are live.</p>
        <ul>
          <li><a href="/api/reflections/ping">/api/reflections/ping</a></li>
          <li><a href="/api/reflections/all">/api/reflections/all</a></li>
          <li><a href="/api/reflections/latest">/api/reflections/latest</a></li>
        </ul>
      </body>
    </html>
  `);
});

export default router;
