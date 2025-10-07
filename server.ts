// <0001fb64> FINAL – Express 5 verified JSON API isolation (reflections functional)
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
    // ✅ Mount API routers on their own parent app
    const apiApp = express();
    await loadRouters(apiApp);
    console.log("<0001fb64> API sub-app mounted first");

    // ✅ Mount sub-app under /api (isolated namespace)
    app.use("/api", apiApp);

    // ✅ Mount dashboard AFTER API namespace
    app.use("/", dashboardRoutes);
    console.log("<0001fb64> dashboardRoutes mounted after /api");

    // ✅ JSON 404 fallback for unknown API routes
    app.use("/api", (_req, res) =>
      res.status(404).json({ error: "API route not found" })
    );

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express 5 server ready at http://localhost:${PORT}`)
    );
  })();
}

export default app;
