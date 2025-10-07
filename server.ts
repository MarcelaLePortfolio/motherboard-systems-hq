// <0001fb5D> Final route order: APIs first, dashboard last
import express from "./scripts/api/express-shared";
import * as path from "path";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();

// ✅ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ Mount dynamic API routers BEFORE dashboard
if (require.main === module) {
  (async () => {
    await loadRouters(app);
    console.log("<0001fb5D> dynamic routers mounted first");

    // ✅ Mount dashboard last to avoid route conflicts
    app.use("/", dashboardRoutes);
    console.log("<0001fb5D> dashboardRoutes mounted last");

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express server listening on http://localhost:${PORT}`)
    );
  })();
}

export default app;
