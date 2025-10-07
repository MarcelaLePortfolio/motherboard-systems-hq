// <0001fb7B> FINAL FIX – Express 5 verified JSON reflections API (direct /api mount, no rewrap)
import express from "./scripts/api/express-shared";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (require.main === module) {
  (async () => {
    // ✅ Create isolated API namespace
    const apiApp = express();
    await loadRouters(apiApp); // mounts /reflections, etc.
    app.use("/api", apiApp); // mount API routers directly
    console.log("<0001fb7B> /api namespace mounted (Express 5 verified)");

    // ✅ Dashboard routes (non-API)
    app.use("/", dashboardRoutes);
    console.log("<0001fb7B> dashboardRoutes mounted after /api");

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express 5 server running at http://localhost:${PORT}`)
    );
  })();
}

export default app;
