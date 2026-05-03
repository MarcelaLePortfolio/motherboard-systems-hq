import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";
import {
  parsePromptToDemoRequest,
  type DemoRequest,
  type DemoTaskDefinition,
} from "./promptToDemoRequest";

export type { DemoRequest, DemoTaskDefinition } from "./promptToDemoRequest";

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
  taskId: string;
  taskName: string;
  traversalPosition: number;
  outcome: TaskOutcome;
  verificationConfirmed: boolean;
  logicalTimestamp: string;
};

export type DemoReport = {
  requestId: string;
  requestSummary: string;
  generatedRequest: DemoRequest;
  admissionDecision: AdmissionResult["decision"];
  denialReasons: string[];
  traversalOrder: string[];
  traversalState: TraversalState;
  taskOutcomes: TaskExecutionRecord[];
  finalDemoResult: "DEMO_SUCCESS" | "DEMO_FAILED";
};

export type RunPromptInput = {
  prompt: string;
  approved?: boolean;
  governanceEvaluated?: boolean;
  authorityOrderingValid?: boolean;
};

export function loadRequestFromFile(requestFilePath: string): DemoRequest {
  const absolutePath = path.resolve(requestFilePath);
  const raw = fs.readFileSync(absolutePath, "utf8");
  return JSON.parse(raw) as DemoRequest;
}

function hasValidTaskStructure(tasks: DemoTaskDefinition[]): boolean {
  if (!Array.isArray(tasks) || tasks.length === 0) {
    return false;
  }

  return tasks.every((task, index) => {
    const expectedId = `task-${index + 1}`;
    return (
      typeof task.id === "string" &&
      task.id === expectedId &&
      typeof task.name === "string" &&
      task.name.trim().length > 0
    );
  });
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

function classifyTaskOutcome(task: DemoTaskDefinition): TaskOutcome {
  const normalized = task.name.toLowerCase();

  if (normalized.includes("fail")) {
    return "FAILED";
  }

  if (normalized.includes("block")) {
    return "BLOCKED";
  }

  return "SUCCESS";
}

function executeBoundedTask(
  task: DemoTaskDefinition,
  traversalPosition: number
): TaskExecutionRecord {
  const outcome = classifyTaskOutcome(task);

  return {
    taskId: task.id,
    taskName: task.name,
    traversalPosition,
    outcome,
    verificationConfirmed: true,
    logicalTimestamp: `STEP_${traversalPosition}`,
  };
}

export function runDeterministicTraversal(
  request: DemoRequest,
  admission: AdmissionResult
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
  taskOutcomes: TaskExecutionRecord[]
): DemoReport {
  const finalDemoResult =
    admission.decision === "ADMITTED" &&
    traversalState === "COMPLETED" &&
    taskOutcomes.length === request.tasks.length &&
    taskOutcomes.every((record) => record.outcome === "SUCCESS")
      ? "DEMO_SUCCESS"
      : "DEMO_FAILED";

  return {
    requestId: request.requestId,
    requestSummary: request.description,
    generatedRequest: request,
    admissionDecision: admission.decision,
    denialReasons: admission.denialReasons,
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
    traversal.taskOutcomes
  );
}

export function runMinimalDemoFromPrompt(input: RunPromptInput): DemoReport {
  const request = parsePromptToDemoRequest(input);
  return runMinimalDemo(request);
}

function main(): void {
  const requestFilePath =
    process.argv[2] ?? "requests/canonical_demo_request.json";
  const request = loadRequestFromFile(requestFilePath);
  const report = runMinimalDemo(request);
  console.log(JSON.stringify(report, null, 2));
}

const isDirectRun =
  typeof process !== "undefined" &&
  Boolean(process.argv[1]) &&
  import.meta.url === pathToFileURL(process.argv[1]).href;

if (isDirectRun) {
  main();
}
