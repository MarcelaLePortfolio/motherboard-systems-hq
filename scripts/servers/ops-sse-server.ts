
export function startOpsSSEServer(req, res) {

  res.write("data: ops-connected\n\n");

  res.flush?.();

}

