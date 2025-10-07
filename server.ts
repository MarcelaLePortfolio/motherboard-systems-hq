// <0001fb61> Final verified route order – reflections API now responding JSON
import express from "./scripts/api/express-shared";
import * as path from "path";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();

// ✅ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (require.main === module) {
  (async () => {
    // ✅ Load all API routers first
    await loadRouters(app);
    console.log("<0001fb61> dynamic routers mounted first");

    // ✅ Mount dashboard AFTER API routers
    app.use("/", dashboardRoutes);
    console.log("<0001fb61> dashboardRoutes mounted after APIs");

    // ✅ Fallback 404 for unknown API routes (must come LAST)
    app.all(/^\/api\/.*/, (_req, res) => {
      res.status(404).json({ error: "API route not found" });
    });

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express server listening on http://localhost:${PORT}`)
    );
  })();
}

export default app;
