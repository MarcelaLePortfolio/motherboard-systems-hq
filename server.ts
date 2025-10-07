// <0001fb7A> FINAL – verified JSON reflections API (direct mount, no double prefix)
import express from "./scripts/api/express-shared";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (require.main === module) {
  (async () => {
    // ✅ Mount reflections and others directly under /api
    await loadRouters(app);
    console.log("<0001fb7A> routers mounted (direct /api base)");

    // ✅ Attach base /api prefix here
    const apiWrapper = express.Router();
    apiWrapper.use("/", app._router); // wrap all existing routers under /api
    const mainApp = express();
    mainApp.use("/api", apiWrapper);

    // ✅ Dashboard routes (non-API)
    mainApp.use("/", dashboardRoutes);

    const PORT = process.env.PORT || 3001;
    mainApp.listen(PORT, () =>
      console.log(`🚀 Express 5 server running at http://localhost:${PORT}`)
    );
  })();
}

export default app;
