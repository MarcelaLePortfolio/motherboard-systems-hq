import Foundation
import CryptoKit

// ELLIS STAGE 3 — NONPRODUCTION APPROVAL FIXTURE
//
// This fixture is intentionally separate from production authority.
// Its P-256 key is generated for isolated testing only.
//
// It does not establish:
// - Independent human administrator identity
// - Physical iPhone Secure Enclave approval
// - Production verification-key registration
// - Credential issuance authorization

enum EllisStage3iPadApprovalFixture {

    struct PreparedApproval {
        let manifest: Data
        let evidence: EllisStage3iPhoneApprovalEvidence
        let trustedKey: EllisStage3TrustedIPhoneKey
    }

    static func prepare() throws -> PreparedApproval {

        let manifest =
            try EllisStage3iPadManifestFixture.canonicalBytes()

        guard EllisStage3iPadApprovalGate.isCanonicalManifest(
            manifest
        ) else {
            throw EllisStage3iPadApprovalError.invalidManifest
        }

        // Explicitly nonproduction software-generated test key.
        // This is not an actual iPhone approval.
        let privateKey = P256.Signing.PrivateKey()
        let publicKeyDER = privateKey.publicKey.derRepresentation

        let fingerprint =
            EllisStage3iPadApprovalGate.sha256Hex(publicKeyDER)

        let trustedKey = EllisStage3TrustedIPhoneKey(
            keyID: "NONPRODUCTION_SIMULATED_IPHONE_KEY",
            publicKeySPKIDER: publicKeyDER,
            fingerprintSHA256Hex: fingerprint
        )

        let signature = try privateKey.signature(
            for: manifest
        )

        let evidence = EllisStage3iPhoneApprovalEvidence(
            version: EllisStage3iPadApprovalGate.evidenceVersion,
            manifestSHA256Hex:
                EllisStage3iPadApprovalGate.sha256Hex(manifest),
            publicKeyID: trustedKey.keyID,
            publicKeyFingerprintSHA256Hex: fingerprint,
            signatureP256DERHex:
                EllisStage3iPadApprovalGate.lowercaseHex(
                    signature.derRepresentation
                ),
            productionIssuance: false
        )

        return PreparedApproval(
            manifest: manifest,
            evidence: evidence,
            trustedKey: trustedKey
        )
    }
}
