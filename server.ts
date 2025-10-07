// <0001fb1b> Canonical Express app initialization – reflections + dashboard fixed
import express from "./scripts/api/express-shared";
import path from "path";
import dashboardRoutes from "./scripts/routes/dashboard";
import listEndpoints from "express-list-endpoints";

const app = express();

// ✅ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
import reflectionsRouter from "./scripts/api/reflections-router";
app.use("/api/reflections", reflectionsRouter);
console.log("<0001fb39> reflectionsRouter mounted (unified)");
import reflectionsRouter from "./scripts/api/reflections-router";
app.use("/api/reflections", reflectionsRouter);
console.log("<0001fb27> reflectionsRouter mounted immediately after middleware (final)");

// ✅ Mount reflections first
console.log("<0001fb22> app._router?.stack length after mount:", app._router?.stack?.length);

// ✅ Mount dashboard routes
app.use("/", dashboardRoutes);
console.log("<0001fb1b> dashboardRoutes mounted at /");

// ✅ Print all active endpoints
process.nextTick(() => {
  console.log("<0001fb25> Registered Express endpoints (final):");
  console.log(listEndpoints(app));
});

// ✅ Launch server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
console.log("<0001fb24> typeof app:", typeof app);
console.log("<0001fb24> has app.use:", typeof app.use);
console.log("<0001fb24> app._router stack length before listen:", app._router?.stack?.length);
  console.log(`🚀 Unified Express instance listening on http://localhost:${PORT}`);
});

// ✅ Export live app (for tests or other imports)
export default app;
