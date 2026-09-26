import assert from "node:assert/strict";
import test from "node:test";

import {
  createExecutionPlan,
} from "../../db/matilda-execution-planning-runtime.js";
import {
  createPreview,
} from "../../db/matilda-preview-runtime.js";
import {
  createPreviewConfirmation,
} from "../../db/matilda-preview-confirmation-runtime.js";

test("durable preview confirmation accepts exact persisted provenance", () => {
  const suffix = `${Date.now()}-${Math.random()}`;

  const plan = createExecutionPlan({
    assignment_id: `assignment-${suffix}`,
    package_id: `package-${suffix}`,
    lineage_id: `lineage-${suffix}`,
    assigned_agent: "cade",
  });

  const preview = createPreview({
    execution_plan_id: plan.execution_plan_id,
    assignment_id: plan.assignment_id,
    package_id: plan.package_id,
    lineage_id: plan.lineage_id,
  });

  const confirmation = createPreviewConfirmation({
    preview_id: preview.preview_id,
    execution_plan_id: plan.execution_plan_id,
    package_id: plan.package_id,
    lineage_id: plan.lineage_id,
    confirmation_actor: "operator",
  });

  assert.equal(confirmation.preview_id, preview.preview_id);
  assert.equal(confirmation.execution_plan_id, plan.execution_plan_id);
  assert.equal(confirmation.package_id, plan.package_id);
  assert.equal(confirmation.lineage_id, plan.lineage_id);
  assert.equal(confirmation.status, "preview_confirmed");
  assert.equal(confirmation.execution_authorized, false);
});

test("preview creation fails closed on plan provenance mismatch", () => {
  const suffix = `${Date.now()}-${Math.random()}`;

  const plan = createExecutionPlan({
    assignment_id: `assignment-${suffix}`,
    package_id: `package-${suffix}`,
    lineage_id: `lineage-${suffix}`,
    assigned_agent: "cade",
  });

  assert.throws(
    () => createPreview({
      execution_plan_id: plan.execution_plan_id,
      assignment_id: plan.assignment_id,
      package_id: `${plan.package_id}-wrong`,
      lineage_id: plan.lineage_id,
    }),
    /Preview provenance does not match persisted execution plan/,
  );
});

test("confirmation fails closed when durable preview evidence is missing", () => {
  assert.throws(
    () => createPreviewConfirmation({
      preview_id: "preview-missing",
      execution_plan_id: "plan-missing",
      package_id: "package-missing",
      lineage_id: "lineage-missing",
      confirmation_actor: "operator",
    }),
    /Preview evidence not found/,
  );
});

test("confirmation fails closed on persisted identity mismatch", () => {
  const suffix = `${Date.now()}-${Math.random()}`;

  const plan = createExecutionPlan({
    assignment_id: `assignment-${suffix}`,
    package_id: `package-${suffix}`,
    lineage_id: `lineage-${suffix}`,
    assigned_agent: "cade",
  });

  const preview = createPreview({
    execution_plan_id: plan.execution_plan_id,
    assignment_id: plan.assignment_id,
    package_id: plan.package_id,
    lineage_id: plan.lineage_id,
  });

  assert.throws(
    () => createPreviewConfirmation({
      preview_id: preview.preview_id,
      execution_plan_id: plan.execution_plan_id,
      package_id: `${plan.package_id}-wrong`,
      lineage_id: plan.lineage_id,
      confirmation_actor: "operator",
    }),
    /Preview confirmation provenance does not match persisted preview/,
  );
});
