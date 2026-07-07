
import { compilePackageToExecutionPlan } from "./package-to-execution-compiler";

import { store } from "../orchestrator/phase18_store.mjs";

/**

 * PEC Runtime Binder

 * Bridges Canonical Package → Execution Graph → Runtime Queue

 */

export function executePackageThroughPEC(pkg) {

  if (!pkg || !pkg.package_id) {

    throw new Error("Invalid package input to PEC binder");

  }

  // 1. Compile Package → Execution Graph

  const taskGraph = compilePackageToExecutionPlan(pkg);

  // 2. Validate minimal structure

  if (!Array.isArray(taskGraph) || taskGraph.length === 0) {

    throw new Error("PEC compilation produced empty execution graph");

  }

  // 3. Enqueue tasks into runtime system (phase18 queue)

  for (const task of taskGraph) {

    store.enqueue(task.kind, {

      task_id: task.id,

      agent: task.agent,

      payload: task.payload,

      dependencies: task.dependencies || [],

      source_package: pkg.package_id

    });

  }

  return {

    ok: true,

    package_id: pkg.package_id,

    tasks_enqueued: taskGraph.length,

    execution_mode: "PEC_RUNTIME_BOUNDED"

  };

}

