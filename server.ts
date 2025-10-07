// <0001fb5F> Express 5-compliant API isolation + verified JSON routing
import express from "./scripts/api/express-shared";
import * as path from "path";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();

// ✅ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ Mount /api routers first
if (require.main === module) {
  (async () => {
    await loadRouters(app);
    console.log("<0001fb5F> dynamic routers mounted first");

    // ✅ 404 fallback (Express 5 compatible)
    app.all("/api/:rest(*)", (_req, res) => {
      res.status(404).json({ error: "API route not found" });
    });

    // ✅ Mount dashboard last to avoid overriding /api/*
    app.use("/", dashboardRoutes);
    console.log("<0001fb5F> dashboardRoutes mounted last");

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () => {
      console.log(`🚀 Express server listening on http://localhost:${PORT}`);
    });
  })();
}

export default app;
