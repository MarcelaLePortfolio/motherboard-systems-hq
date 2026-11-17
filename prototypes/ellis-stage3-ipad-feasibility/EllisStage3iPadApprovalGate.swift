import Foundation
import CryptoKit

// ELLIS STAGE 3 — ISOLATED NONPRODUCTION IPAD APPROVAL GATE
//
// No production issuance, network transport, administrative
// authorization, persistent signing keys, or live UI integration.
//
// A valid iPhone signature proves key possession only.
// It does not establish independent human authority.

enum EllisStage3iPadApprovalError: Error {
    case invalidManifest
    case invalidEvidence
    case untrustedKey
    case invalidSignature
    case confirmationRequired
}

struct EllisStage3iPhoneApprovalEvidence {
    let version: String
    let manifestSHA256Hex: String
    let publicKeyID: String
    let publicKeyFingerprintSHA256Hex: String
    let signatureP256DERHex: String
    let productionIssuance: Bool
}

struct EllisStage3TrustedIPhoneKey {
    let keyID: String
    let publicKeySPKIDER: Data
    let fingerprintSHA256Hex: String
}

struct EllisStage3iPadVerifiedSigningEvidence {
    let manifestSHA256Hex: String
    let iphoneApprovalVerified: Bool
    let ipadPublicKeyEd25519: Data
    let ipadSignatureEd25519: Data
    let exactBytesVerified: Bool
    let productionIssuance: Bool
}

enum EllisStage3iPadApprovalGate {
    static let evidenceVersion =
        "ELLIS_IPHONE_APPROVAL_EVIDENCE_V1"

    private static let manifestVersion =
        "ELLIS_CREDENTIAL_ISSUANCE_MANIFEST_V1"

    static func lowercaseHex(_ bytes: Data) -> String {
        bytes.map { String(format: "%02x", $0) }.joined()
    }

    static func sha256Hex(_ bytes: Data) -> String {
        lowercaseHex(Data(SHA256.hash(data: bytes)))
    }

    private static func isLowercaseHex(
        _ text: String,
        bytes: Int
    ) -> Bool {
        guard text.utf8.count == bytes * 2 else {
            return false
        }

        return text.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) ||
            ($0 >= 97 && $0 <= 102)
        }
    }

    private static func canonicalTimestamp(
        _ value: String
    ) -> Date? {
        guard value.utf8.count == 24 else {
            return nil
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!

        guard let date = formatter.date(from: value),
              formatter.string(from: date) == value else {
            return nil
        }

        return date
    }

    static func isCanonicalManifest(_ bytes: Data) -> Bool {
        guard let text = String(data: bytes, encoding: .utf8),
              let decoded = try? JSONSerialization.jsonObject(
                  with: bytes
              ),
              let fields = decoded as? [String],
              fields.count == 10,
              fields[0] == manifestVersion,
              fields[4] == "ISSUE",
              isLowercaseHex(fields[6], bytes: 32),
              let approved = canonicalTimestamp(fields[8]),
              let expires = canonicalTimestamp(fields[9]),
              expires > approved else {
            return false
        }

        for index in [1, 2, 3, 5, 7] {
            let identifier = fields[index]

            guard !identifier.isEmpty,
                  !identifier.unicodeScalars.contains(
                      where: { CharacterSet.whitespacesAndNewlines.contains($0) }
                  ) else {
                return false
            }
        }

        guard let serialized = try? JSONSerialization.data(
            withJSONObject: fields,
            options: [.fragmentsAllowed]
        ) else {
            return false
        }

        return serialized == bytes &&
            String(data: serialized, encoding: .utf8) == text
    }

    static func verifyIphoneApproval(
        manifest: Data,
        evidence: EllisStage3iPhoneApprovalEvidence,
        trustedKey: EllisStage3TrustedIPhoneKey?
    ) -> Bool {
        guard isCanonicalManifest(manifest),
              evidence.version == evidenceVersion,
              evidence.productionIssuance == false,
              isLowercaseHex(
                  evidence.manifestSHA256Hex,
                  bytes: 32
              ),
              isLowercaseHex(
                  evidence.publicKeyFingerprintSHA256Hex,
                  bytes: 32
              ),
              evidence.manifestSHA256Hex == sha256Hex(manifest),
              let trustedKey,
              !evidence.publicKeyID.isEmpty,
              trustedKey.keyID == evidence.publicKeyID,
              isLowercaseHex(
                  trustedKey.fingerprintSHA256Hex,
                  bytes: 32
              ),
              trustedKey.fingerprintSHA256Hex ==
                  sha256Hex(trustedKey.publicKeySPKIDER),
              evidence.publicKeyFingerprintSHA256Hex ==
                  trustedKey.fingerprintSHA256Hex,
              evidence.signatureP256DERHex.utf8.count >= 16,
              evidence.signatureP256DERHex.utf8.count.isMultiple(of: 2),
              evidence.signatureP256DERHex.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57) ||
                  ($0 >= 97 && $0 <= 102)
              }),
              let signatureData = Data(
                  hexString: evidence.signatureP256DERHex
              ),
              let publicKey = try? P256.Signing.PublicKey(
                  derRepresentation: trustedKey.publicKeySPKIDER
              ),
              let signature = try? P256.Signing.ECDSASignature(
                  derRepresentation: signatureData
              ) else {
            return false
        }

        return publicKey.isValidSignature(
            signature,
            for: manifest
        )
    }

    static func signAfterVerification(
        manifest: Data,
        evidence: EllisStage3iPhoneApprovalEvidence,
        trustedKey: EllisStage3TrustedIPhoneKey?,
        explicitlyConfirmed: Bool
    ) throws -> EllisStage3iPadVerifiedSigningEvidence {
        guard isCanonicalManifest(manifest) else {
            throw EllisStage3iPadApprovalError.invalidManifest
        }

        guard verifyIphoneApproval(
            manifest: manifest,
            evidence: evidence,
            trustedKey: trustedKey
        ) else {
            throw EllisStage3iPadApprovalError.invalidEvidence
        }

        guard explicitlyConfirmed else {
            throw EllisStage3iPadApprovalError.confirmationRequired
        }

        // No persistent or production signing key is created.
        let ipadPrivateKey = Curve25519.Signing.PrivateKey()
        let ipadPublicKey = ipadPrivateKey.publicKey
        let signature = try ipadPrivateKey.signature(for: manifest)

        guard ipadPublicKey.isValidSignature(
            signature,
            for: manifest
        ) else {
            throw EllisStage3iPadApprovalError.invalidSignature
        }

        return EllisStage3iPadVerifiedSigningEvidence(
            manifestSHA256Hex: sha256Hex(manifest),
            iphoneApprovalVerified: true,
            ipadPublicKeyEd25519: ipadPublicKey.rawRepresentation,
            ipadSignatureEd25519: signature,
            exactBytesVerified: true,
            productionIssuance: false
        )
    }
}

private extension Data {
    init?(hexString: String) {
        guard hexString.utf8.count.isMultiple(of: 2) else {
            return nil
        }

        var bytes = [UInt8]()
        bytes.reserveCapacity(hexString.utf8.count / 2)

        let characters = Array(hexString.utf8)

        for index in stride(
            from: 0,
            to: characters.count,
            by: 2
        ) {
            guard let high = UInt8(
                String(decoding: [characters[index]], as: UTF8.self),
                radix: 16
            ),
            let low = UInt8(
                String(decoding: [characters[index + 1]], as: UTF8.self),
                radix: 16
            ) else {
                return nil
            }

            bytes.append(high * 16 + low)
        }

        self.init(bytes)
    }
}
