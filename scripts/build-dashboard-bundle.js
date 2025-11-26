import esbuild from "esbuild";
import path from "path";

const entryPoints = [
  "public/js/dashboard-status.js",
  "public/js/dashboard-sse.js",
  "public/js/dashboard-utils.js",
  "public/js/dashboard-chat.js"
];

esbuild.build({
  entryPoints,
  bundle: true,
  minify: true,
  sourcemap: false,
  outfile: "public/bundle.js",
  platform: "browser",
  target: "es2020"
}).then(() => {
  console.log("✨ Dashboard bundle built successfully → public/bundle.js");
}).catch((err) => {
  console.error("❌ Bundling failed", err);
  process.exit(1);
});
