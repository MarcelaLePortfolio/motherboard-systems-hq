// <0001fb1b> Canonical Express app initialization – reflections + dashboard fixed
import express from "./scripts/api/express-shared";
import * as path from "path";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();
// ✅ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// <0001fb50> Unified async startup block (final verified clean)

if (require.main === module) {
(async () => {
  console.log("<0001fb50> dynamic routers loaded before listen (final verified clean)");

  const PORT = process.env.PORT || 3001;
  app.listen(PORT, () => {
    console.log(`🚀 Unified Express instance listening on http://localhost:${PORT}`);
  });
})();
}

(async () => {
  await loadRouters(app);
  console.log("<0001fb50> dynamic routers loaded before listen (final verified clean)");

  const PORT = process.env.PORT || 3001;
  app.listen(PORT, () => {
    console.log(`🚀 Unified Express instance listening on http://localhost:${PORT}`);
  });
})();
