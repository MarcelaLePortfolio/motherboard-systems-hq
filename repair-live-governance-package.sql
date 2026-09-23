.bail on
PRAGMA foreign_keys = ON;

BEGIN IMMEDIATE;

UPDATE governance_packages
SET
  scope = (
    SELECT approved_scope
    FROM matilda_canonical_packages
    WHERE package_id = 'pkg-68dfc4bc-791d-4156-b32a-e51e458b3160'
      AND package_version = 1
      AND status = 'canonical_approved'
  ),
  constraints = (
    SELECT approved_constraints
    FROM matilda_canonical_packages
    WHERE package_id = 'pkg-68dfc4bc-791d-4156-b32a-e51e458b3160'
      AND package_version = 1
      AND status = 'canonical_approved'
  )
WHERE package_id = 'pkg-68dfc4bc-791d-4156-b32a-e51e458b3160'
  AND package_version = 1
  AND scope IS NULL
  AND constraints IS NULL
  AND EXISTS (
    SELECT 1
    FROM governance_delegations
    WHERE package_id = 'pkg-68dfc4bc-791d-4156-b32a-e51e458b3160'
      AND package_version = 1
      AND authorization_state = 'AUTHORIZED'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM governance_validation_results
    WHERE package_id = 'pkg-68dfc4bc-791d-4156-b32a-e51e458b3160'
      AND package_version = 1
  );

SELECT CASE changes()
  WHEN 1 THEN 'REPAIR_APPLIED'
  ELSE 'REPAIR_REFUSED'
END AS repair_result;

SELECT
  p.package_id,
  p.package_version,
  p.scope,
  p.constraints,
  d.delegation_id,
  d.authorization_state,
  v.validation_result_id,
  v.validation_status
FROM governance_packages p
JOIN governance_delegations d
  ON d.package_id = p.package_id
 AND d.package_version = p.package_version
LEFT JOIN governance_validation_results v
  ON v.package_id = p.package_id
 AND v.package_version = p.package_version
WHERE p.package_id = 'pkg-68dfc4bc-791d-4156-b32a-e51e458b3160'
  AND p.package_version = 1;

COMMIT;

PRAGMA integrity_check;
