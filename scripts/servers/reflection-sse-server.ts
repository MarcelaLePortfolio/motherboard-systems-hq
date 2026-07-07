
export function startReflectionSSEServer(req, res) {

  res.write("data: connected\n\n");

  res.flush?.();

}

