
import governedPlanningRouter from "../routes/governed-planning-route.mjs";

function findPostRoute(router, path) {

  const stack = router?.stack || [];

  return stack.find((layer) => {

    const route = layer.route;

    return (

      route &&

      route.path === path &&

      route.methods &&

      route.methods.post === true

    );

  });

}

function makeMockResponse() {

  const state = {

    status_code: null,

    payload: null,

  };

  return {

    status(code) {

      state.status_code = code;

      return this;

    },

    json(payload) {

      state.payload = payload;

      return this;

    },

    get state() {

      return state;

    },

  };

}

const layer = findPostRoute(

  governedPlanningRouter,

  "/api/governed-planning/dry-run",

);

if (!layer) {

  throw new Error("governed planning POST route not found");

}

const handler = layer.route.stack.find((entry) => entry.method === "post")?.handle;

if (typeof handler !== "function") {

  throw new Error("governed planning POST handler not found");

}

const req = {

  body: {

    actor: "Matilda",

    target: "Cade",

    objective: "Prepare governed engineering plan",

    requested_outcome: "Dry-run reconciliation-ready planning artifact",

    source: "inprocess_route_smoke",

    tags: ["governance", "dry_run"],

    proposed_changes: [

      {

        file: "docs/contracts/example.md",

        operation: "modify",

        content: "planned only",

      },

    ],

  },

};

const res = makeMockResponse();

await handler(req, res);

const payload = res.state.payload;

const bundle = payload?.bundle || payload?.response?.bundle || payload?.response || payload;

const authority =

  bundle?.execution_authority ||

  bundle?.response?.execution_authority ||

  bundle?.artifacts?.response?.execution_authority ||

  {};

const failed =

  res.state.status_code !== 200 ||

  payload?.ok !== true ||

  authority.mutation_performed === true ||

  authority.shell_execution_performed === true ||

  authority.autonomous_execution_performed === true;

console.log(JSON.stringify({

  ok: !failed,

  route_smoke: "inprocess_governed_planning_route",

  status_code: res.state.status_code,

  payload_ok: payload?.ok === true,

  mutation_performed: authority.mutation_performed === true,

  shell_execution_performed: authority.shell_execution_performed === true,

  autonomous_execution_performed: authority.autonomous_execution_performed === true,

}, null, 2));

if (failed) process.exit(1);

