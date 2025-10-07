// <0001fb43> express v5 endpoint introspection helper
import type { Express } from "express";

export function listExpress5Endpoints(app: Express) {
  const stack = app._router?.stack || [];
  const endpoints = [];
  for (const layer of stack) {
    if (layer.route) {
      const methods = Object.keys(layer.route.methods).map(m => m.toUpperCase());
      endpoints.push({ path: layer.route.path, methods });
    } else if (layer.name === "router" && layer.handle?.stack) {
      for (const sub of layer.handle.stack) {
        if (sub.route) {
          const methods = Object.keys(sub.route.methods).map(m => m.toUpperCase());
          endpoints.push({ path: sub.route.path, methods });
        }
      }
    }
  }
  return endpoints;
}
