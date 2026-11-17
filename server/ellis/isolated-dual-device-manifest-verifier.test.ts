import assert from "node:assert/strict";
import {
  createHash,
  generateKeyPairSync,
  sign,
} from "node:crypto";
import test from "node:test";

import {
  IPHONE_APPROVAL_EVIDENCE_VERSION,
  type IphoneApprovalEvidence,
  type TrustedIphoneApprovalKey,
} from "./isolated-iphone-approval-evidence.js";

import {
  DUAL_DEVICE_VERIFICATION_CLASSIFICATION,
  verifyIsolatedDualDeviceManifest,
  type DualDeviceVerificationDependencies,
  type IpadManifestSignatureEvidence,
  type TrustedIpadManifestKey,
} from "./isolated-dual-device-manifest-verifier.js";

const manifest = Buffer.from(JSON.stringify([
  "ELLIS_CREDENTIAL_ISSUANCE_MANIFEST_V1",
  "NONPRODUCTION_ADMINISTRATOR",
  "NONPRODUCTION_AUTHORIZATION",
  "NONPRODUCTION_DEPARTMENT",
  "ISSUE",
  "NONPRODUCTION_CREDENTIAL",
  "0".repeat(64),
  "NONPRODUCTION_ISSUANCE",
  "2026-11-06T00:00:00.000Z",
  "2026-11-07T00:00:00.000Z",
]), "utf8");

const hash = (bytes: Uint8Array): string =>
  createHash("sha256").update(bytes).digest("hex");

const iphone = generateKeyPairSync("ec", {
  namedCurve: "prime256v1",
});

const ipad = generateKeyPairSync("ed25519");

const iphonePublic = iphone.publicKey.export({
  format: "der",
  type: "spki",
}) as Buffer;

const ipadPublic = ipad.publicKey.export({
  format: "der",
  type: "spki",
}) as Buffer;

const trustedIphone: TrustedIphoneApprovalKey = {
  key_id: "NONPRODUCTION_IPHONE",
  public_key_spki_der: iphonePublic,
  fingerprint_sha256_hex: hash(iphonePublic),
};

const trustedIpad: TrustedIpadManifestKey = {
  key_id: "NONPRODUCTION_IPAD",
  public_key_spki_der: ipadPublic,
  fingerprint_sha256_hex: hash(ipadPublic),
};

const iphoneEvidence: IphoneApprovalEvidence = {
  version: IPHONE_APPROVAL_EVIDENCE_VERSION,
  manifest_sha256_hex: hash(manifest),
  public_key_id: trustedIphone.key_id,
  public_key_fingerprint_sha256_hex:
    trustedIphone.fingerprint_sha256_hex,
  signature_p256_der_hex: sign(
    "sha256",
    manifest,
    iphone.privateKey,
  ).toString("hex"),
  production_issuance: false,
};

const ipadEvidence: IpadManifestSignatureEvidence = {
  signature_ref:
    `ed25519-manifest:${trustedIpad.key_id}:` +
    sign(null, manifest, ipad.privateKey).toString("hex"),
  manifest_sha256_hex: hash(manifest),
  production_issuance: false,
};

const dependencies: DualDeviceVerificationDependencies = {
  resolveTrustedIphoneTestKey: (id) =>
    id === trustedIphone.key_id ? trustedIphone : null,
  resolveTrustedIpadTestKey: (id) =>
    id === trustedIpad.key_id ? trustedIpad : null,
};

function check(
  bytes: Uint8Array = manifest,
  phone: unknown = iphoneEvidence,
  tablet: unknown = ipadEvidence,
  trust: DualDeviceVerificationDependencies = dependencies,
): boolean {
  const result = verifyIsolatedDualDeviceManifest(
    trust,
    bytes,
    phone,
    tablet,
  );

  assert.equal(
    result.classification,
    DUAL_DEVICE_VERIFICATION_CLASSIFICATION,
  );

  return result.verified;
}

test("valid isolated dual signatures verify exact manifest", () => {
  assert.equal(check(), true);
});

test("modified manifest is rejected", () => {
  const modified = Buffer.from(manifest);
  modified[modified.length - 2] ^= 1;
  assert.equal(check(modified), false);
});

test("different canonical manifest is rejected", () => {
  const fields = JSON.parse(manifest.toString("utf8"));
  fields[5] = "DIFFERENT_NONPRODUCTION_CREDENTIAL";
  assert.equal(
    check(Buffer.from(JSON.stringify(fields))),
    false,
  );
});

test("invalid iPhone approval is rejected", () => {
  assert.equal(
    check(manifest, {
      ...iphoneEvidence,
      signature_p256_der_hex: "00",
    }),
    false,
  );
});

test("missing iPhone evidence is rejected", () => {
  assert.equal(check(manifest, null), false);
});

test("wrong iPad signature is rejected", () => {
  const other = generateKeyPairSync("ed25519");
  assert.equal(
    check(manifest, iphoneEvidence, {
      ...ipadEvidence,
      signature_ref:
        `ed25519-manifest:${trustedIpad.key_id}:` +
        sign(null, manifest, other.privateKey).toString("hex"),
    }),
    false,
  );
});

test("unknown iPad key is rejected", () => {
  assert.equal(
    check(manifest, iphoneEvidence, {
      ...ipadEvidence,
      signature_ref:
        ipadEvidence.signature_ref.replace(
          trustedIpad.key_id,
          "UNKNOWN_IPAD",
        ),
    }),
    false,
  );
});

test("mismatched iPad key fingerprint is rejected", () => {
  assert.equal(
    check(manifest, iphoneEvidence, ipadEvidence, {
      ...dependencies,
      resolveTrustedIpadTestKey: () => ({
        ...trustedIpad,
        fingerprint_sha256_hex: "0".repeat(64),
      }),
    }),
    false,
  );
});

test("untrusted iPhone key is rejected", () => {
  assert.equal(
    check(manifest, iphoneEvidence, ipadEvidence, {
      ...dependencies,
      resolveTrustedIphoneTestKey: () => null,
    }),
    false,
  );
});

test("missing iPad trust resolver is rejected", () => {
  assert.equal(
    check(manifest, iphoneEvidence, ipadEvidence, {
      ...dependencies,
      resolveTrustedIpadTestKey: undefined,
    } as unknown as DualDeviceVerificationDependencies),
    false,
  );
});

test("throwing trust resolver fails closed", () => {
  assert.equal(
    check(manifest, iphoneEvidence, ipadEvidence, {
      ...dependencies,
      resolveTrustedIpadTestKey: () => {
        throw new Error("Unavailable");
      },
    }),
    false,
  );
});

test("production claim is rejected", () => {
  assert.equal(
    check(manifest, iphoneEvidence, {
      ...ipadEvidence,
      production_issuance: true,
    }),
    false,
  );
});

test("extra iPad evidence fields are rejected", () => {
  assert.equal(
    check(manifest, iphoneEvidence, {
      ...ipadEvidence,
      public_key_spki_der: ipadPublic,
    }),
    false,
  );
});

test("malformed iPad provenance is rejected", () => {
  assert.equal(
    check(manifest, iphoneEvidence, {
      ...ipadEvidence,
      signature_ref: "ed25519:NONPRODUCTION_IPAD:00",
    }),
    false,
  );
});

test("iPad signature cannot transfer to another manifest", () => {
  const fields = JSON.parse(manifest.toString("utf8"));
  fields[7] = "ANOTHER_NONPRODUCTION_ISSUANCE";
  const otherManifest = Buffer.from(JSON.stringify(fields));

  const otherIphoneEvidence = {
    ...iphoneEvidence,
    manifest_sha256_hex: hash(otherManifest),
    signature_p256_der_hex: sign(
      "sha256",
      otherManifest,
      iphone.privateKey,
    ).toString("hex"),
  };

  assert.equal(
    check(otherManifest, otherIphoneEvidence, ipadEvidence),
    false,
  );
});
