// <0001fb60> Express 5 regex-safe fallback + verified JSON routing
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
    await loadRouters(app);
    console.log("<0001fb60> dynamic routers mounted first");

    // ✅ Express 5-compatible 404 fallback for any /api/* path
    app.all(/^\/api\/.*/, (_req, res) => {
      res.status(404).json({ error: "API route not found" });
    });

    // ✅ Mount dashboard last
    app.use("/", dashboardRoutes);
    console.log("<0001fb60> dashboardRoutes mounted last");

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express server listening on http://localhost:${PORT}`)
    );
  })();
}

export default app;
