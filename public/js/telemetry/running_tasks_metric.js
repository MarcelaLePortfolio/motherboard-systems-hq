/*
PHASE 65B TELEMETRY HYDRATION
Running Tasks Metric

STRICT RULES:
DATA ONLY CHANGE
NO LAYOUT TOUCH
NO DOM STRUCTURE MUTATION
NO CONTAINER INSERTION
*/

(function(){

let activeTasks = new Set();

function isStartEvent(type){
    return (
        type === "task.created" ||
        type === "task.started" ||
        type === "task.running"
    );
}

function isTerminalEvent(type){
    return (
        type === "task.completed" ||
        type === "task.failed" ||
        type === "task.cancelled"
    );
}

function updateMetric(){

    const metric = document.querySelector('[data-metric="running-tasks"]');

    if(!metric) return;

    metric.textContent = activeTasks.size;

}

function processEvent(evt){

    if(!evt) return;

    const type = evt.type || evt.event || evt.name;
    const id =
        evt.task_id ||
        evt.taskId ||
        evt.id;

    if(!type || !id) return;

    if(isStartEvent(type)){
        activeTasks.add(id);
    }

    if(isTerminalEvent(type)){
        activeTasks.delete(id);
    }

    updateMetric();

}

function attachStream(){

    if(!window.taskEventsStream) return;

    window.taskEventsStream.addEventListener("message", function(e){

        try{

            const data = JSON.parse(e.data);

            processEvent(data);

        }catch(err){
            console.warn("running_tasks_metric parse error");
        }

    });

}

function bootstrap(){

    attachStream();
    updateMetric();

}

if(document.readyState === "loading"){
    document.addEventListener("DOMContentLoaded", bootstrap);
}else{
    bootstrap();
}

})();
