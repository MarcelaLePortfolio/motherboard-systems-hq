// <0001fb5E> Final baseline – guaranteed JSON API routing
import express from "./scripts/api/express-shared";
import * as path from "path";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();

// ✅ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ Mount /api routes first, protected from dashboard interference
if (require.main === module) {
  (async () => {
    await loadRouters(app);
    console.log("<0001fb5E> dynamic routers mounted first");

    // 🚧 Block dashboard from overriding /api/*
    app.use("/api", (req, res, next) => next());

    // ✅ Mount dashboard last (catch-all for non-API routes)
    app.use("/", dashboardRoutes);
    console.log("<0001fb5E> dashboardRoutes mounted last");

    // ✅ Fallback 404 for unhandled API routes
    app.use("/api/*", (_req, res) =>
      res.status(404).json({ error: "API route not found" })
    );

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express server listening on http://localhost:${PORT}`)
    );
  })();
}

export default app;
