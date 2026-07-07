
import { evaluateAuthority } from "./authority-gate";

export function authorityMiddleware(req: any, res: any, next: any) {

  const mode = (req.query.mode as any) ?? "diagnostic";

  req.authority = evaluateAuthority({

    mode,

    source: "middleware"

  });

  next();

}

