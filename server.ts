import reflectionsRouter from "./scripts/api/reflections-router";
// <0001fb1b> Canonical Express app initialization – reflections + dashboard fixed
import express from "express";
import path from "path";
import dashboardRoutes from "./scripts/routes/dashboard";
import reflectionsRouterModule from "./scripts/api/reflections-router";
const reflectionsRouter = reflectionsRouterModule.default || reflectionsRouterModule;
import listEndpoints from "express-list-endpoints";

const app = express();

// ✅ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ Mount reflections first
app.use("/api/reflections", reflectionsRouter);
console.log("<0001fb1b> reflectionsRouter mounted at /api/reflections");
console.log("<0001fb22> app._router?.stack length after mount:", app._router?.stack?.length);
console.log("<0001fb22> reflectionsRouter stack length at mount:", reflectionsRouter.stack?.length);
console.log("<0001fb21> typeof reflectionsRouter:", typeof reflectionsRouter);
console.log("<0001fb21> reflectionsRouter keys:", Object.keys(reflectionsRouter));

// ✅ Mount dashboard routes
app.use("/", dashboardRoutes);
console.log("<0001fb1b> dashboardRoutes mounted at /");

// ✅ Print all active endpoints
console.log("<0001fb1b> Registered Express endpoints:");
console.log(listEndpoints(app));

// ✅ Launch server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Unified Express instance listening on http://localhost:${PORT}`);
});

// ✅ Export live app (for tests or other imports)
export default app;
