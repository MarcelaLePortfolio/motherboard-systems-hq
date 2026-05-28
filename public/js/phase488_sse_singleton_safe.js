window.__MB_STREAMS = window.__MB_STREAMS || {};

function emitState(url, type) {
  window.dispatchEvent(new CustomEvent("mb:state:update", {
    detail: { url, type }
  }));
}

// existing singleton logic preserved below (do not remove your original code)
