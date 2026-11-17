import {
  createHash,
  createPublicKey,
  verify,
  type KeyObject,
} from "node:crypto";

export const IPHONE_APPROVAL_EVIDENCE_VERSION =
  "ELLIS_IPHONE_APPROVAL_EVIDENCE_V1" as const;

const MANIFEST_VERSION = "ELLIS_CREDENTIAL_ISSUANCE_MANIFEST_V1";
const IDENTIFIER = /^[^\s]+$/u;
const DIGEST = /^[0-9a-f]{64}$/;
const HEX = /^(?:[0-9a-f]{2})+$/;
const TIMESTAMP =
  /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/;

export type IphoneApprovalEvidence = Readonly<{
  version: typeof IPHONE_APPROVAL_EVIDENCE_VERSION;
  manifest_sha256_hex: string;
  public_key_id: string;
  public_key_fingerprint_sha256_hex: string;
  signature_p256_der_hex: string;
  production_issuance: false;
}>;

export type TrustedIphoneApprovalKey = Readonly<{
  key_id: string;
  public_key_spki_der: Uint8Array;
  fingerprint_sha256_hex: string;
}>;

export type IphoneApprovalVerificationDependencies = Readonly<{
  resolveTrustedTestKey: (
    keyId: string,
  ) => TrustedIphoneApprovalKey | null | undefined;
}>;

export type IphoneApprovalVerificationResult = Readonly<{
  verified: boolean;
  classification: "NONPRODUCTION_SIGNATURE_VERIFICATION_ONLY";
}>;

function sha256Hex(bytes: Uint8Array): string {
  return createHash("sha256").update(bytes).digest("hex");
}

function validTimestamp(value: unknown): value is string {
  if (typeof value !== "string" || !TIMESTAMP.test(value)) {
    return false;
  }

  const parsed = new Date(value);
  return !Number.isNaN(parsed.valueOf()) &&
    parsed.toISOString() === value;
}

export function isCanonicalIssuanceManifest(
  bytes: Uint8Array,
): boolean {
  try {
    const raw = Buffer.from(bytes);
    const text = raw.toString("utf8");

    if (!Buffer.from(text, "utf8").equals(raw)) {
      return false;
    }

    const fields: unknown = JSON.parse(text);

    if (
      !Array.isArray(fields) ||
      fields.length !== 10 ||
      !fields.every((field) => typeof field === "string")
    ) {
      return false;
    }

    const [
      version,
      administratorId,
      authorizationRef,
      departmentId,
      operation,
      credentialId,
      credentialDigest,
      issuanceId,
      approvedAt,
      expiresAt,
    ] = fields;

    if (
      version !== MANIFEST_VERSION ||
      operation !== "ISSUE" ||
      ![
        administratorId,
        authorizationRef,
        departmentId,
        credentialId,
        issuanceId,
      ].every((value) => IDENTIFIER.test(value)) ||
      !DIGEST.test(credentialDigest) ||
      !validTimestamp(approvedAt) ||
      !validTimestamp(expiresAt) ||
      Date.parse(expiresAt) <= Date.parse(approvedAt)
    ) {
      return false;
    }

    return JSON.stringify(fields) === text;
  } catch {
    return false;
  }
}

function isStrictEvidence(
  value: unknown,
): value is IphoneApprovalEvidence {
  if (
    value === null ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    return false;
  }

  const record = value as Record<string, unknown>;
  const expected = [
    "version",
    "manifest_sha256_hex",
    "public_key_id",
    "public_key_fingerprint_sha256_hex",
    "signature_p256_der_hex",
    "production_issuance",
  ];

  if (
    Object.keys(record).length !== expected.length ||
    !expected.every((key) =>
      Object.prototype.hasOwnProperty.call(record, key)
    )
  ) {
    return false;
  }

  return record.version === IPHONE_APPROVAL_EVIDENCE_VERSION &&
    typeof record.manifest_sha256_hex === "string" &&
    DIGEST.test(record.manifest_sha256_hex) &&
    typeof record.public_key_id === "string" &&
    IDENTIFIER.test(record.public_key_id) &&
    typeof record.public_key_fingerprint_sha256_hex === "string" &&
    DIGEST.test(record.public_key_fingerprint_sha256_hex) &&
    typeof record.signature_p256_der_hex === "string" &&
    HEX.test(record.signature_p256_der_hex) &&
    record.production_issuance === false;
}

function isP256PublicKey(key: KeyObject): boolean {
  return key.type === "public" &&
    key.asymmetricKeyType === "ec" &&
    key.asymmetricKeyDetails?.namedCurve === "prime256v1";
}

const REJECTED: IphoneApprovalVerificationResult = Object.freeze({
  verified: false,
  classification: "NONPRODUCTION_SIGNATURE_VERIFICATION_ONLY",
});

const VERIFIED: IphoneApprovalVerificationResult = Object.freeze({
  verified: true,
  classification: "NONPRODUCTION_SIGNATURE_VERIFICATION_ONLY",
});

export function verifyIsolatedIphoneApprovalEvidence(
  dependencies: IphoneApprovalVerificationDependencies,
  manifestBytes: Uint8Array,
  evidence: unknown,
): IphoneApprovalVerificationResult {
  try {
    if (
      !(manifestBytes instanceof Uint8Array) ||
      !isCanonicalIssuanceManifest(manifestBytes) ||
      !isStrictEvidence(evidence) ||
      !dependencies ||
      typeof dependencies.resolveTrustedTestKey !== "function"
    ) {
      return REJECTED;
    }

    if (
      evidence.manifest_sha256_hex !== sha256Hex(manifestBytes)
    ) {
      return REJECTED;
    }

    const trusted = dependencies.resolveTrustedTestKey(
      evidence.public_key_id,
    );

    if (
      !trusted ||
      trusted.key_id !== evidence.public_key_id ||
      !(trusted.public_key_spki_der instanceof Uint8Array) ||
      !DIGEST.test(trusted.fingerprint_sha256_hex)
    ) {
      return REJECTED;
    }

    const trustedBytes = Buffer.from(trusted.public_key_spki_der);
    const actualFingerprint = sha256Hex(trustedBytes);

    if (
      actualFingerprint !== trusted.fingerprint_sha256_hex ||
      actualFingerprint !==
        evidence.public_key_fingerprint_sha256_hex
    ) {
      return REJECTED;
    }

    const publicKey = createPublicKey({
      key: trustedBytes,
      format: "der",
      type: "spki",
    });

    if (!isP256PublicKey(publicKey)) {
      return REJECTED;
    }

    const signature = Buffer.from(
      evidence.signature_p256_der_hex,
      "hex",
    );

    if (
      signature.length < 8 ||
      signature[0] !== 0x30 ||
      !verify(
        "sha256",
        Buffer.from(manifestBytes),
        {
          key: publicKey,
          dsaEncoding: "der",
        },
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
