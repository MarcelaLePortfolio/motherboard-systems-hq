const state = {
  task: "",
  isLoading: false,
  output: ""
};

async function handleSubmit(event) {
  event.preventDefault();
  state.isLoading = true;
  state.output = "";

  document.querySelector(".loader").style.display = "block";

  const response = await fetch("/api/task", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ task: state.task }),
  });

  const text = await response.text();
  state.output = text;
  state.isLoading = false;

  document.querySelector(".loader").style.display = "none";
  const outputEl = document.querySelector("pre");
  if (outputEl) {
    outputEl.textContent = text;
  } else {
    const pre = document.createElement("pre");
    pre.textContent = text;
    document.body.appendChild(pre);
  }
}
