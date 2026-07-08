
import type { Express } from "express";

import { authorityMiddleware } from "./authority/authority-middleware";

export function applyAuthority(app: Express) {

  app.use(authorityMiddleware);

}

