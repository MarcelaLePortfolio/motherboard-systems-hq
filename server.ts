// <0001fb6B> FINAL VERIFIED – reflections API JSON isolation enforced
import express from "./scripts/api/express-shared";
import * as path from "path";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (require.main === module) {
  (async () => {
    // ✅ Create isolated API namespace router
    const apiRouter = express.Router();
    await loadRouters(apiRouter); // mounts /reflections, etc.
    app.use("/api", apiRouter);
    console.log("<0001fb6B> /api namespace mounted and isolated");

    // ✅ Ensure dashboard loads AFTER /api
    app.use("/", dashboardRoutes);
    console.log("<0001fb6B> dashboardRoutes mounted after /api");

    // ✅ JSON fallback for all unknown API routes
    app.use("/api", (_req, res) => {
      res.status(404).json({ error: "API route not found" });
    });

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express 5 server running at http://localhost:${PORT}`)
    );
  })();
}

export default app;
