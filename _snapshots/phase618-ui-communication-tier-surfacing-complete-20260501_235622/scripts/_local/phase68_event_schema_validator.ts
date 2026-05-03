type PrimitiveType = "string" | "number" | "object";

type ValidationIssueLevel = "FAIL" | "WARN";

type ValidationIssue = {
  level: ValidationIssueLevel;
  message: string;
};

type EventRecord = Record<string, unknown>;

const REQUIRED_TASK_FIELDS: Record<string, PrimitiveType> = {
  event_type: "string",
  task_id: "string",
  run_id: "string",
  ts: "number",
  state: "string",
};

const OPTIONAL_TASK_FIELDS: Record<string, PrimitiveType> = {
  actor: "string",
  lease_epoch: "number",
  metadata: "object",
};

const ALLOWED_TASK_EVENT_TYPES = new Set([
  "task.created",
  "task.started",
  "task.running",
  "task.completed",
  "task.failed",
  "task.cancelled",
]);

const TERMINAL_STATES = new Set(["completed", "failed", "cancelled"]);
const NON_TERMINAL_STATES = new Set(["created", "started", "running"]);

function getType(value: unknown): PrimitiveType | "null" | "array" | "boolean" | "undefined" {
  if (value === null) return "null";
  if (Array.isArray(value)) return "array";
  return typeof value as PrimitiveType | "boolean" | "undefined";
}

function parseInputArg(): string {
  const input = process.argv[2];
  if (!input) {
    throw new Error("Usage: tsx scripts/_local/phase68_event_schema_validator.ts '<json-array-of-events>'");
  }
  return input;
}

function parseEvents(raw: string): EventRecord[] {
  const parsed = JSON.parse(raw) as unknown;

  if (!Array.isArray(parsed)) {
    throw new Error("Input must be a JSON array of telemetry events.");
  }

  for (const entry of parsed) {
    if (typeof entry !== "object" || entry === null || Array.isArray(entry)) {
      throw new Error("Each telemetry event must be a JSON object.");
    }
  }

  return parsed as EventRecord[];
}

function validateFieldTypes(
  event: EventRecord,
  fields: Record<string, PrimitiveType>,
  issues: ValidationIssue[],
  missingFieldLevel: ValidationIssueLevel,
): void {
  for (const [fieldName, expectedType] of Object.entries(fields)) {
    if (!(fieldName in event)) {
      issues.push({
        level: missingFieldLevel,
        message: `missing required field: ${fieldName}`,
      });
      continue;
    }

    const actualType = getType(event[fieldName]);
    if (actualType !== expectedType) {
      issues.push({
        level: "FAIL",
        message: `invalid type for ${fieldName}: expected ${expectedType}, received ${actualType}`,
      });
    }
  }
}

function validateOptionalFieldTypes(
  event: EventRecord,
  fields: Record<string, PrimitiveType>,
  issues: ValidationIssue[],
): void {
  for (const [fieldName, expectedType] of Object.entries(fields)) {
    if (!(fieldName in event)) continue;

    const actualType = getType(event[fieldName]);
    if (actualType !== expectedType) {
      issues.push({
        level: "FAIL",
        message: `invalid type for optional field ${fieldName}: expected ${expectedType}, received ${actualType}`,
      });
    }
  }
}

function validateUnknownFields(
  event: EventRecord,
  issues: ValidationIssue[],
): void {
  const allowedFields = new Set([
    ...Object.keys(REQUIRED_TASK_FIELDS),
    ...Object.keys(OPTIONAL_TASK_FIELDS),
  ]);

  for (const key of Object.keys(event)) {
    if (!allowedFields.has(key)) {
      issues.push({
        level: "WARN",
        message: `unknown field present: ${key}`,
      });
    }
  }
}

function validateEventType(event: EventRecord, issues: ValidationIssue[]): void {
  const value = event.event_type;
  if (typeof value !== "string") return;

  if (!ALLOWED_TASK_EVENT_TYPES.has(value)) {
    issues.push({
      level: "WARN",
      message: `unknown event_type: ${value}`,
    });
  }
}

function validateState(event: EventRecord, issues: ValidationIssue[]): void {
  const value = event.state;
  if (typeof value !== "string") return;

  if (!TERMINAL_STATES.has(value) && !NON_TERMINAL_STATES.has(value)) {
    issues.push({
      level: "WARN",
      message: `unknown state: ${value}`,
    });
  }
}

function validateLogicalConsistency(event: EventRecord, issues: ValidationIssue[]): void {
  const eventType = typeof event.event_type === "string" ? event.event_type : null;
  const state = typeof event.state === "string" ? event.state : null;

  if (!eventType || !state) return;

  if (eventType === "task.completed" && state !== "completed") {
    issues.push({
      level: "FAIL",
      message: `event_type/state mismatch: task.completed requires state=completed`,
    });
  }

  if (eventType === "task.failed" && state !== "failed") {
    issues.push({
      level: "FAIL",
      message: `event_type/state mismatch: task.failed requires state=failed`,
    });
  }

  if (eventType === "task.cancelled" && state !== "cancelled") {
    issues.push({
      level: "FAIL",
      message: `event_type/state mismatch: task.cancelled requires state=cancelled`,
    });
  }
}

function validateTaskEvent(event: EventRecord): ValidationIssue[] {
  const issues: ValidationIssue[] = [];

  validateFieldTypes(event, REQUIRED_TASK_FIELDS, issues, "FAIL");
  validateOptionalFieldTypes(event, OPTIONAL_TASK_FIELDS, issues);
  validateUnknownFields(event, issues);
  validateEventType(event, issues);
  validateState(event, issues);
  validateLogicalConsistency(event, issues);

  return issues;
}

function printReport(events: EventRecord[]): number {
  let failCount = 0;
  let warnCount = 0;

  console.log("PHASE 68 EVENT SCHEMA VALIDATOR");
  console.log("Telemetry drift detection — NON BLOCKING MODE");
  console.log("---------------------------------------------");
  console.log(`events_received=${events.length}`);
  console.log("");

  events.forEach((event, index) => {
    const issues = validateTaskEvent(event);

    console.log(`event[${index}]`);
    console.log(JSON.stringify(event, null, 2));

    if (issues.length === 0) {
      console.log("PASS: event matches contract");
    } else {
      for (const issue of issues) {
        console.log(`${issue.level}: ${issue.message}`);
        if (issue.level === "FAIL") failCount += 1;
        if (issue.level === "WARN") warnCount += 1;
      }
    }

    console.log("");
  });

  console.log("SUMMARY");
  console.log(`fails=${failCount}`);
  console.log(`warnings=${warnCount}`);

  if (failCount > 0) {
    console.log("RESULT: FAIL");
    return 1;
  }

  console.log("RESULT: PASS");
  return 0;
}

function main(): void {
  try {
    const raw = parseInputArg();
    const events = parseEvents(raw);
    const exitCode = printReport(events);
    process.exit(exitCode);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`VALIDATOR ERROR: ${message}`);
    process.exit(1);
  }
}

main();
