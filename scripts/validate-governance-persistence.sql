
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

PRAGMA foreign_keys;

INSERT INTO governance_delegations (

  delegation_id,

  package_id,

  package_version,

  authorization_state,

  authorization_timestamp,

  delegated_by,

  created_at

) VALUES (

  'test-invalid-delegation',

  'missing-package',

  1,

  'AUTHORIZED',

  datetime('now'),

  'test-user',

  datetime('now')

);

ROLLBACK;

