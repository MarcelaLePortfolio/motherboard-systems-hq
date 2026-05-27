/* eslint-disable import/no-commonjs */
#!/bin/bash
pm2 delete all

pm2 start server.js --name dashboard-server
pm2 start --name cade -- node --loader tsx ./scripts/_local/agent-runtime/launch-cade.ts
pm2 start --name effie -- node --loader tsx ./scripts/_local/agent-runtime/launch-effie.ts
pm2 start --name matilda -- node --loader tsx ./scripts/_local/agent-runtime/launch-matilda.ts
pm2 start --name cade-processor -- node --loader tsx ./scripts/_local/agent-runtime/cade-processor.ts

pm2 save
pm2 ls
