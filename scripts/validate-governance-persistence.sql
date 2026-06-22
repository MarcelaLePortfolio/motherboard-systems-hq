
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- 1. Confirm FK enforcement is active

PRAGMA foreign_keys;

-- 2. Invalid Delegation: should fail

INSERT INTO governance_delegations (

  delegation_id, package_id, package_version, authorization_state, authorization_timestamp, delegated_by

) VALUES (

  'test-invalid-delegation', 'missing-package', 1, 'AUTHORIZED', datetime('now'), 'test-user'

);

ROLLBACK;

