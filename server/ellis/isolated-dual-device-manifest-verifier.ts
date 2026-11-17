import {
  createHash,
  createPublicKey,
  verify,
} from "node:crypto";

import {
  isCanonicalIssuanceManifest,
  verifyIsolatedIphoneApprovalEvidence,
  type IphoneApprovalEvidence,
  type TrustedIphoneApprovalKey,
} from "./isolated-iphone-approval-evidence.js";

export const DUAL_DEVICE_VERIFICATION_CLASSIFICATION =
  "NONPRODUCTION_DUAL_SIGNATURE_VERIFICATION_ONLY" as const;

export type TrustedIpadManifestKey = Readonly<{
  key_id: string;
  public_key_spki_der: Uint8Array;
  fingerprint_sha256_hex: string;
}>;

export type IpadManifestSignatureEvidence = Readonly<{
  signature_ref: string;
  manifest_sha256_hex: string;
  production_issuance: false;
}>;

export type DualDeviceVerificationDependencies = Readonly<{
  resolveTrustedIphoneTestKey: (
    keyId: string,
  ) => TrustedIphoneApprovalKey | null | undefined;
  resolveTrustedIpadTestKey: (
    keyId: string,
  ) => TrustedIpadManifestKey | null | undefined;
}>;

export type DualDeviceVerificationResult = Readonly<{
  verified: boolean;
  classification: typeof DUAL_DEVICE_VERIFICATION_CLASSIFICATION;
}>;

const REJECTED: DualDeviceVerificationResult = Object.freeze({
  verified: false,
  classification: DUAL_DEVICE_VERIFICATION_CLASSIFICATION,
});

const VERIFIED: DualDeviceVerificationResult = Object.freeze({
  verified: true,
  classification: DUAL_DEVICE_VERIFICATION_CLASSIFICATION,
});

const DIGEST = /^[0-9a-f]{64}$/;
const KEY_ID = /^[A-Za-z0-9_-]{1,128}$/;
const SIGNATURE =
  /^ed25519-manifest:([A-Za-z0-9_-]{1,128}):([0-9a-f]{128})$/;

function sha256Hex(bytes: Uint8Array): string {
  return createHash("sha256").update(bytes).digest("hex");
}

function strictIpadEvidence(
  value: unknown,
): value is IpadManifestSignatureEvidence {
  if (
    value === null ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    return false;
  }

  const record = value as Record<string, unknown>;
  const fields = [
    "signature_ref",
    "manifest_sha256_hex",
    "production_issuance",
  ];

  return Object.keys(record).length === fields.length &&
    fields.every((field) =>
      Object.prototype.hasOwnProperty.call(record, field)
    ) &&
    typeof record.signature_ref === "string" &&
    SIGNATURE.test(record.signature_ref) &&
    typeof record.manifest_sha256_hex === "string" &&
    DIGEST.test(record.manifest_sha256_hex) &&
    record.production_issuance === false;
}

/**
 * Isolated nonproduction cryptographic verification only.
 *
 * This function cannot:
 * - Establish independent human administrator authority.
 * - Establish physical-device identity or private-key custody.
 * - Register, approve, or revoke verification keys.
 * - Consume an issuance authorization.
 * - Issue, activate, or rotate credentials.
 *
 * Trusted test keys must come from verifier-controlled dependencies,
 * never from the submitted signature evidence.
 */
export function verifyIsolatedDualDeviceManifest(
  dependencies: DualDeviceVerificationDependencies,
  manifestBytes: Uint8Array,
  iphoneEvidence: IphoneApprovalEvidence | unknown,
  ipadEvidence: IpadManifestSignatureEvidence | unknown,
): DualDeviceVerificationResult {
  try {
    if (
      !(manifestBytes instanceof Uint8Array) ||
      !isCanonicalIssuanceManifest(manifestBytes) ||
      !dependencies ||
      typeof dependencies.resolveTrustedIphoneTestKey !== "function" ||
      typeof dependencies.resolveTrustedIpadTestKey !== "function" ||
      !strictIpadEvidence(ipadEvidence)
    ) {
      return REJECTED;
    }

    if (
      ipadEvidence.manifest_sha256_hex !== sha256Hex(manifestBytes)
    ) {
      return REJECTED;
    }

    const iphoneResult = verifyIsolatedIphoneApprovalEvidence(
      {
        resolveTrustedTestKey:
          dependencies.resolveTrustedIphoneTestKey,
      },
      manifestBytes,
      iphoneEvidence,
    );

    if (!iphoneResult.verified) {
      return REJECTED;
    }

    const parsed = SIGNATURE.exec(ipadEvidence.signature_ref);

    if (!parsed) {
      return REJECTED;
    }

    const [, keyId, signatureHex] = parsed;

    if (!KEY_ID.test(keyId)) {
      return REJECTED;
    }

    const trusted = dependencies.resolveTrustedIpadTestKey(keyId);

    if (
      !trusted ||
      trusted.key_id !== keyId ||
      !(trusted.public_key_spki_der instanceof Uint8Array) ||
      !DIGEST.test(trusted.fingerprint_sha256_hex)
    ) {
      return REJECTED;
    }

    const publicKeyBytes = Buffer.from(
      trusted.public_key_spki_der,
    );

    if (
      sha256Hex(publicKeyBytes) !==
      trusted.fingerprint_sha256_hex
    ) {
      return REJECTED;
    }

    const publicKey = createPublicKey({
      key: publicKeyBytes,
      format: "der",
      type: "spki",
    });

    if (
      publicKey.type !== "public" ||
      publicKey.asymmetricKeyType !== "ed25519"
    ) {
      return REJECTED;
    }

    const signature = Buffer.from(signatureHex, "hex");

    if (
      signature.length !== 64 ||
      !verify(
        null,
        Buffer.from(manifestBytes),
        publicKey,
        signature,
      )
    ) {
      return REJECTED;
    }

    return VERIFIED;
  } catch {
    return REJECTED;
  }
}
