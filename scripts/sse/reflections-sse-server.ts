
export function startReflectionStream(req, res) {

  res.write("data: stream-start\n\n");

  res.flush?.();

}

