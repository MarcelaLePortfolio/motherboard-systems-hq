/*
PHASE 64 — AGENT ACTIVITY WIRING
Behavior-only layer.
NO layout mutation.
Derives agent activity from existing task-events stream.
*/

(function () {

const AGENTS = ["Matilda","Atlas","Cade","Effie"];

const activity = {
  Matilda: {state:"idle", ts:0},
  Atlas: {state:"idle", ts:0},
  Cade: {state:"idle", ts:0},
  Effie: {state:"idle", ts:0}
};

function markBusy(agent){
  if(!activity[agent]) return;
  activity[agent].state="busy";
  activity[agent].ts=Date.now();
  render(agent);
}

function markIdle(agent){
  if(!activity[agent]) return;
  activity[agent].state="idle";
  activity[agent].ts=Date.now();
  render(agent);
}

function render(agent){

  const el=document.querySelector(`[data-agent="${agent}"]`);
  if(!el) return;

  el.dataset.state=activity[agent].state;

  const badge=el.querySelector(".agent-state");
  if(!badge) return;

  if(activity[agent].state==="busy"){
    badge.textContent="ACTIVE";
    badge.classList.add("agent-active");
  } else {
    badge.textContent="IDLE";
    badge.classList.remove("agent-active");
  }

}

function wireTaskEvents(){

  if(!window.taskEventsStream) return;

  window.taskEventsStream.addEventListener("message",(e)=>{

    let data;

    try{
      data=JSON.parse(e.data);
    }catch{
      return;
    }

    const agent=data.actor;
    const state=data.state;

    if(!AGENTS.includes(agent)) return;

    if(state==="started" || state==="running"){
      markBusy(agent);
    }

    if(
      state==="completed" ||
      state==="failed" ||
      state==="cancelled"
    ){
      markIdle(agent);
    }

  });

}

function bootstrap(){

  AGENTS.forEach(a=>render(a));

  wireTaskEvents();

}

document.addEventListener("DOMContentLoaded",bootstrap);

})();
