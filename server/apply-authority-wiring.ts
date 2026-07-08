
import type { Express } from "express";

import { applyAuthority } from "./apply-authority";

export function wireSystem(app: Express) {

  applyAuthority(app);

}

