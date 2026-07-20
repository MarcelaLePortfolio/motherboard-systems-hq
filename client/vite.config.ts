import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Isolated bootstrap configuration for the first shell corridor.
// Deliberately does not reference, proxy to, or assume anything about
// server/index.ts or the existing /ui route. This app runs entirely
// on its own dev server for independent validation. Vite commands
// are expected to run from inside client/, so no explicit root is set.
export default defineConfig({
  plugins: [react()],
});
