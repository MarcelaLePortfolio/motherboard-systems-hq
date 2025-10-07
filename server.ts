// <0001fb6E> Express 5 verified JSON reflections API (direct mount)
import express from "./scripts/api/express-shared";
import * as path from "path";
import { loadRouters } from "./scripts/utils/loadRouters";
import dashboardRoutes from "./scripts/routes/dashboard";

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (require.main === module) {
  (async () => {
    await loadRouters(app); // directly mounts /api/reflections
    console.log("<0001fb6E> routers mounted directly at /api/*");

    app.use("/", dashboardRoutes);
    console.log("<0001fb6E> dashboardRoutes mounted after /api");

    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () =>
      console.log(`🚀 Express server running at http://localhost:${PORT}`)
    );
  })();
}

export default app;
