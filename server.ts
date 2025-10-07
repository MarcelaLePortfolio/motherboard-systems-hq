// <0001fb76> FINAL FIX – Express 5 verified JSON reflections API (base prefix applied here)
import express from "./scripts/api/express-shared";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (require.main === module) {
  (async () => {
    // ✅ Mount all routers under /api
    const apiApp = express();
    await loadRouters(apiApp);
    app.use("/api", apiApp);
    console.log("<0001fb76> API routers mounted under /api namespace");

    // ✅ Dashboard last
    app.use("/", dashboardRoutes);
    console.log("<0001fb76> dashboardRoutes mounted after /api");

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express 5 server running on http://localhost:${PORT}`)
    );
  })();
}

export default app;
