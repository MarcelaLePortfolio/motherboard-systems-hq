// <0001fb84> FINAL FIX – reflections JSON API functional (flattened)
import express from "./scripts/api/express-shared";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (require.main === module) {
  (async () => {
    // ✅ Mount routers directly at /api/<name>
    await loadRouters(app);
    console.log("<0001fb84> routers mounted directly (final verified)");

    // ✅ Dashboard routes
    app.use("/", dashboardRoutes);

    // ✅ Fallback for unknown API routes
    app.use((req, res) => {
      if (req.path.startsWith("/api/")) {
        return res.status(404).json({ error: "API route not found" });
      }
      res.status(404).send("<h1>404 – Page not found</h1>");
    });

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express 5 server running at http://localhost:${PORT}`)
    );
  })();
}

export default app;
