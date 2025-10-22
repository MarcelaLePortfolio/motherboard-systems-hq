const statusCells = {
  Cade: document.querySelector('#status-cade'),
  Matilda: document.querySelector('#status-matilda'),
  Effie: document.querySelector('#status-effie')
};

const evtSource = new EventSource('/events/agents');
evtSource.onmessage = (event) => {
  try {
    const data = JSON.parse(event.data);
    if (statusCells[data.agent]) {
      statusCells[data.agent].textContent = data.status;
      statusCells[data.agent].className =
        data.status === "busy" ? "status-busy" :
        data.status === "online" ? "status-online" :
        "status-unknown";
    }
  } catch (err) {
    console.error("SSE parse error", err);
  }
};

evtSource.onerror = (e) => console.error("SSE connection error:", e);
