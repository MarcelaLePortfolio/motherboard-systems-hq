import assert from "node:assert/strict";
import test from "node:test";

import {
  assertPathAllowed,
  assertMutationScopeAllowed,
} from "./mutation-scope-guard.mjs";

test("allows an explicitly declared file", () => {
  assert.equal(
    assertPathAllowed({
      candidatePath: "src/allowed.ts",
      allowedPaths: ["src/allowed.ts"],
      forbiddenPaths: [],
    }),
    true
  );
});

test("rejects a sibling file sharing an allowed filename prefix", () => {
  assert.throws(
    () => assertPathAllowed({
      candidatePath: "src/allowed.ts.backup",
      allowedPaths: ["src/allowed.ts"],
      forbiddenPaths: [],
    }),
    { code: "OUTSIDE_MUTATION_SCOPE" }
  );
});

test("rejects a sibling directory sharing an allowed prefix", () => {
  assert.throws(
    () => assertPathAllowed({
      candidatePath: "src-safe/escape.ts",
      allowedPaths: ["src"],
      forbiddenPaths: [],
    }),
    { code: "OUTSIDE_MUTATION_SCOPE" }
  );
});

test("rejects parent traversal outside allowed scope", () => {
  assert.throws(
    () => assertPathAllowed({
      candidatePath: "src/../../outside.ts",
      allowedPaths: ["src"],
      forbiddenPaths: [],
    }),
    { code: "OUTSIDE_MUTATION_SCOPE" }
  );
});

test("does not confuse a forbidden directory with its sibling", () => {
  assert.equal(
    assertPathAllowed({
      candidatePath: "secrets-public/example.ts",
      allowedPaths: ["secrets-public"],
      forbiddenPaths: ["secrets"],
    }),
    true
  );
});

test("rejects an actual forbidden descendant", () => {
  assert.throws(
    () => assertPathAllowed({
      candidatePath: "secrets/private.env",
      allowedPaths: ["secrets"],
      forbiddenPaths: ["secrets"],
    }),
    { code: "FORBIDDEN_MUTATION_PATH" }
  );
});

test("allows a descendant of an authorized directory", () => {
  assert.equal(
    assertPathAllowed({
      candidatePath: "src/components/example.ts",
      allowedPaths: ["src"],
      forbiddenPaths: [],
    }),
    true
  );
});

test("rejects empty paths", () => {
  assert.throws(
    () => assertPathAllowed({
      candidatePath: "",
      allowedPaths: [""],
      forbiddenPaths: [],
    }),
    TypeError
  );
});

test("rejects NUL-containing paths", () => {
  assert.throws(
    () => assertPathAllowed({
      candidatePath: "src/\0escape.ts",
      allowedPaths: ["src"],
      forbiddenPaths: [],
    }),
    TypeError
  );
});

test("rejects invalid scope list types", () => {
  assert.throws(
    () => assertPathAllowed({
      candidatePath: "src/example.ts",
      allowedPaths: "src",
      forbiddenPaths: [],
    }),
    TypeError
  );
});

test("enforces envelope mutation scope", () => {
  const envelope = {
    mutation_scope: {
      allowed_paths: ["src"],
      forbidden_paths: ["src/protected"],
    },
  };

  assert.equal(
    assertMutationScopeAllowed(envelope, "src/allowed.ts"),
    true
  );

  assert.throws(
    () => assertMutationScopeAllowed(
      envelope,
      "src/protected/secret.ts"
    ),
    { code: "FORBIDDEN_MUTATION_PATH" }
  );
});
