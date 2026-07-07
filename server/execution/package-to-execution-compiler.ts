
import type { ExecutionTask } from "../orchestrator/phase18_store.mjs";

export type CanonicalPackage = {

  package_id: string;

  requested_outcome: string;

  constraints?: string[];

  allowed_actions?: string[];

  lifecycle_state: string;

};

type Agent = "cade" | "effie" | "matilda";

/**

 * PEC (Package Execution Compiler)

 * Converts governed intent into deterministic execution graph

 */

export function compilePackageToExecutionPlan(pkg: CanonicalPackage): ExecutionTask[] {

  const tasks: ExecutionTask[] = [];

  // 1. Always start with interpretation validation (Matilda)

  tasks.push({

    id: `${pkg.package_id}:interpret`,

    kind: "matilda.interpret",

    agent: "matilda",

    payload: {

      package_id: pkg.package_id,

      intent: pkg.requested_outcome

    }

  });

  // 2. Planning phase (Cade)

  tasks.push({

    id: `${pkg.package_id}:plan`,

    kind: "cade.plan",

    agent: "cade",

    dependencies: [`${pkg.package_id}:interpret`],

    payload: {

      constraints: pkg.constraints ?? [],

      allowed_actions: pkg.allowed_actions ?? [],

      goal: pkg.requested_outcome

    }

  });

  // 3. Execution phase (Effie)

  tasks.push({

    id: `${pkg.package_id}:execute`,

    kind: "effie.execute",

    agent: "effie",

    dependencies: [`${pkg.package_id}:plan`],

    payload: {

      goal: pkg.requested_outcome

    }

  });

  // 4. Finalization / validation (Matilda)

  tasks.push({

    id: `${pkg.package_id}:validate`,

    kind: "matilda.validate",

    agent: "matilda",

    dependencies: [`${pkg.package_id}:execute`],

    payload: {

      package_id: pkg.package_id

    }

  });

  return tasks;

}

