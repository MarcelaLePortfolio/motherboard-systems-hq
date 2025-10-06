// <0001fad0> Entry point ensuring single Express app instance
import app from "./server";

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Unified app listening on http://localhost:${PORT}`);
});

// <0001fad5> Debug after launch – list all live Express routes
setTimeout(() => {
  const extractRoutes = (stack: any[], prefix = ""): string[] =>
    stack.flatMap((layer) => {
      if (layer.route) {
        return Object.keys(layer.route.methods).map(
          (m) => `${m.toUpperCase()} ${prefix}${layer.route.path}`
        );
      } else if (layer.name === "router" && layer.handle.stack) {
        return extractRoutes(
          layer.handle.stack,
          prefix +
            (layer.regexp?.source
              .replace("^\\", "/")
              .replace("\\/?(?=\\/|$)", "") || "")
        );
      }
      return [];
    });

  const routes = extractRoutes(app._router?.stack || []);
  console.log("🧩 [Post-launch] All registered routes:", routes);
}, 500);
