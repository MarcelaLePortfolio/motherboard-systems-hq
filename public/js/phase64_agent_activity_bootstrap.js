/*
PHASE 64 — SAFE BOOTSTRAP LOADER
Ensures agent activity wiring loads without modifying layout.
*/

(function(){

function loadPhase64(){

  if(window.__PHASE64_AGENT_WIRE_LOADED__) return;

  window.__PHASE64_AGENT_WIRE_LOADED__=true;

  const s=document.createElement("script");

  s.src="/js/phase64_agent_activity_wire.js";
  s.defer=true;

  document.head.appendChild(s);

}

if(document.readyState==="loading"){
  document.addEventListener("DOMContentLoaded",loadPhase64);
}else{
  loadPhase64();
}

})();
