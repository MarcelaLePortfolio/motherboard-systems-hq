import esbuild from "esbuild";

const entryFile = "public/js/dashboard-bundle-entry.js";

esbuild.build({
  entryPoints: [entryFile],
  bundle: true,
  minify: true,
  sourcemap: false,
  outfile: "public/bundle.js",
  platform: "browser",
  target: "es2020",
}).then(() => {
  console.log("✨ Dashboard bundle built successfully → public/bundle.js");
}).catch((err) => {
  console.error("❌ Bundling failed", err);
  process.exit(1);
});
