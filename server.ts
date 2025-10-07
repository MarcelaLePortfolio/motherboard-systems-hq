// <0001fb1b> Canonical Express app initialization – reflections + dashboard fixed
import express from "./scripts/api/express-shared";
import path from "path";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();

// ✅ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
setTimeout(async () => {
}, 0);
setTimeout(() => {
}, 1000);
console.log("<0001fb27> reflectionsRouter mounted immediately after middleware (final)");

// ✅ Mount reflections first
console.log("<0001fb22> app._router?.stack length after mount:", app._router?.stack?.length);

// ✅ Mount dashboard routes
import reflectionsRouter from "./scripts/api/reflections-router";
app.use("/api/reflections", reflectionsRouter);
console.log("<0001fb48> reflectionsRouter mounted cleanly before dashboard");

app.use("/", dashboardRoutes);
console.log("<0001fb1b> dashboardRoutes mounted at /");

// ✅ Print all active endpoints
process.nextTick(() => {
  console.log("<0001fb25> Registered Express endpoints (final):");
  console.log(listExpress5Endpoints ? listExpress5Endpoints(app) : []);
});

import { listExpress5Endpoints } from "./scripts/utils/listExpress5Endpoints";
setTimeout(() => {
  console.log("<0001fb43> Express 5 routes snapshot:", listExpress5Endpoints(app));
}, 2000);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Unified Express instance listening on http://localhost:${PORT}`);
});
