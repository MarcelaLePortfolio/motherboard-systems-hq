(function(){

function byId(id){
  return document.getElementById(id);
}

const recent = byId("tasks-widget");
const history = byId("recentLogs");

if(!recent && !history){
  console.log("phase457: no task panels found");
  return;
}

let tasks = [];

function render(){

  if(recent){
    recent.innerHTML =
      tasks.slice(0,6)
      .map(t =>
        "<div class='task-row'>" +
        "<span>"+(t.name || "task")+"</span>" +
        "<span>"+(t.status || "")+"</span>" +
        "</div>"
      ).join("");
  }

  if(history){
    history.innerHTML =
      tasks.slice(0,12)
      .map(t =>
        "<div class='history-row'>" +
        (t.name || "task") +
        " : " +
        (t.status || "") +
        "</div>"
      ).join("");
  }

}

window.addEventListener("mb.task.event", e=>{

  const ev = e.detail || {};

  tasks.unshift({
    name: ev.task || ev.id || "task",
    status: ev.status || ev.event || "update"
  });

  if(tasks.length > 50){
    tasks.length = 50;
  }

  render();

});

console.log("phase457 task panels restored");

})();
