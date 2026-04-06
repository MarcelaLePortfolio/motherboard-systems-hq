export type DemoRequest = {
  requestId: string;
  description: string;
  approved: boolean;
  governanceEvaluated: boolean;
  authorityOrderingValid: boolean;
  tasks: DemoTaskDefinition[];
};

export type DemoTaskDefinition = {
  id: "task-1" | "task-2" | "task-3";
  name:
    | "Dependency Verification"
    | "Governance Review Confirmation"
    | "Execution Readiness Assessment";
};

export type AdmissionResult = {
  requestId: string;
  approved: boolean;
  governanceEvaluated: boolean;
  authorityOrderingValid: boolean;
  structureIntegrityValid: boolean;
  decision: "ADMITTED" | "DENIED";
  denialReasons: string[];
};

export type TraversalState =
  | "NOT_STARTED"
  | "IN_PROGRESS"
  | "COMPLETED"
  | "BLOCKED";

export type TaskOutcome = "SUCCESS" | "FAILED" | "BLOCKED";

export type TaskExecutionRecord = {
  taskId: DemoTaskDefinition["id"];
  taskName: DemoTaskDefinition["name"];
  traversalPosition: number;
  outcome: TaskOutcome;
  verificationConfirmed: boolean;
  logicalTimestamp: string;
};

export type DemoReport = {
  requestId: string;
  requestSummary: string;
  admissionDecision: AdmissionResult["decision"];
  traversalOrder: string[];
  traversalState: TraversalState;
  taskOutcomes: TaskExecutionRecord[];
  finalDemoResult: "DEMO_SUCCESS" | "DEMO_FAILED";
};

const EXPECTED_TASK_ORDER: DemoTaskDefinition["id"][] = [
  "task-1",
  "task-2",
  "task-3",
];

function hasValidTaskStructure(tasks: DemoTaskDefinition[]): boolean {
  if (tasks.length !== EXPECTED_TASK_ORDER.length) {
    return false;
  }

  return tasks.every((task, index) => task.id === EXPECTED_TASK_ORDER[index]);
}

export function runAdmissionCheck(request: DemoRequest): AdmissionResult {
  const denialReasons: string[] = [];
  const structureIntegrityValid = hasValidTaskStructure(request.tasks);

  if (!request.approved) {
    denialReasons.push("Approval missing");
  }

  if (!request.governanceEvaluated) {
    denialReasons.push("Governance evaluation missing");
  }

  if (!request.authorityOrderingValid) {
    denialReasons.push("Authority ordering invalid");
  }

  if (!structureIntegrityValid) {
    denialReasons.push("Task structure invalid");
  }

  return {
    requestId: request.requestId,
    approved: request.approved,
    governanceEvaluated: request.governanceEvaluated,
    authorityOrderingValid: request.authorityOrderingValid,
    structureIntegrityValid,
    decision: denialReasons.length === 0 ? "ADMITTED" : "DENIED",
    denialReasons,
  };
}

function executeBoundedTask(
  task: DemoTaskDefinition,
  traversalPosition: number,
): TaskExecutionRecord {
  const logicalTimestamp = `STEP_${traversalPosition}`;

  switch (task.id) {
    case "task-1":
      return {
        taskId: task.id,
        taskName: task.name,
        traversalPosition,
        outcome: "SUCCESS",
        verificationConfirmed: true,
        logicalTimestamp,
      };
    case "task-2":
      return {
        taskId: task.id,
        taskName: task.name,
        traversalPosition,
        outcome: "SUCCESS",
        verificationConfirmed: true,
        logicalTimestamp,
      };
    case "task-3":
      return {
        taskId: task.id,
        taskName: task.name,
        traversalPosition,
        outcome: "SUCCESS",
        verificationConfirmed: true,
        logicalTimestamp,
      };
    default: {
      const exhaustiveCheck: never = task.id;
      throw new Error(`Unhandled task id: ${exhaustiveCheck}`);
    }
  }
}

export function runDeterministicTraversal(
  request: DemoRequest,
  admission: AdmissionResult,
): { traversalState: TraversalState; taskOutcomes: TaskExecutionRecord[] } {
  if (admission.decision !== "ADMITTED") {
    return {
      traversalState: "BLOCKED",
      taskOutcomes: [],
    };
  }

  const taskOutcomes: TaskExecutionRecord[] = [];

  for (const [index, task] of request.tasks.entries()) {
    const record = executeBoundedTask(task, index + 1);
    taskOutcomes.push(record);

    if (record.outcome !== "SUCCESS") {
      return {
        traversalState: "BLOCKED",
        taskOutcomes,
      };
    }
  }

  return {
    traversalState: "COMPLETED",
    taskOutcomes,
  };
}

export function buildDemoReport(
  request: DemoRequest,
  admission: AdmissionResult,
  traversalState: TraversalState,
  taskOutcomes: TaskExecutionRecord[],
): DemoReport {
  const finalDemoResult =
    admission.decision === "ADMITTED" &&
    traversalState === "COMPLETED" &&
    taskOutcomes.length === EXPECTED_TASK_ORDER.length &&
    taskOutcomes.every((record) => record.outcome === "SUCCESS")
      ? "DEMO_SUCCESS"
      : "DEMO_FAILED";

  return {
    requestId: request.requestId,
    requestSummary: request.description,
    admissionDecision: admission.decision,
    traversalOrder: request.tasks.map((task) => task.name),
    traversalState,
    taskOutcomes,
    finalDemoResult,
  };
}

export function runMinimalDemo(request: DemoRequest): DemoReport {
  const admission = runAdmissionCheck(request);
  const traversal = runDeterministicTraversal(request, admission);

  return buildDemoReport(
    request,
    admission,
    traversal.traversalState,
    traversal.taskOutcomes,
  );
}

const defaultDemoRequest: DemoRequest = {
  requestId: "fl4-demo-request-001",
  description:
    "Create a project to evaluate deployment readiness for a new service. Include three tasks: dependency verification, governance review, and execution readiness assessment. Require approval before any execution preparation.",
  approved: true,
  governanceEvaluated: true,
  authorityOrderingValid: true,
  tasks: [
    {
      id: "task-1",
      name: "Dependency Verification",
    },
    {
      id: "task-2",
      name: "Governance Review Confirmation",
    },
    {
      id: "task-3",
      name: "Execution Readiness Assessment",
    },
  ],
};

if (require.main === module) {
  const report = runMinimalDemo(defaultDemoRequest);
  console.log(JSON.stringify(report, null, 2));
}
