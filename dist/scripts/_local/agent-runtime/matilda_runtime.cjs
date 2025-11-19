"use strict";
const fs = require('fs');
const path = require('path');
function log(message) {
    const logPath = path.join(__dirname, '../../../memory/matilda_runtime_log.json');
    const logData = { timestamp: new Date().toISOString(), message };
    fs.appendFileSync(logPath, JSON.stringify(logData) + '\n');
}
function delegateTasks() {
    const chain = [
        {
            agent: "cade",
            type: "transform_json",
            payload: {
                input: "memory/source_data.json",
                output: "memory/step1_sorted.json",
                operation: "sort_by",
                key: "name"
            }
        },
        {
            agent: "cade",
            type: "transform_json",
            payload: {
                input: "memory/step1_sorted.json",
                output: "memory/step2_roles_upper.json",
                operation: "transform_values",
                key: "role",
                transform: "toUpperCase"
            }
        },
        {
            agent: "cade",
            type: "transform_json",
            payload: {
                input: "memory/step2_roles_upper.json",
                output: "memory/step3_only_desktop.json",
                operation: "filter_values",
                key: "role",
                value: "DESKTOP"
            }
        },
        {
            agent: "cade",
            type: "transform_json",
            payload: {
                input: "memory/step3_only_desktop.json",
                output: "memory/final_grouped.json",
                operation: "group_by",
                key: "role"
            }
        }
    ];
    const chainPath = path.join(__dirname, '../../../memory/agent_chain_state.json');
    fs.writeFileSync(chainPath, JSON.stringify({ chain }, null, 2));
    log('Matilda delegated multi-step JSON transform chain to Cade');
}
function process() {
    log('Matilda runtime started');
    delegateTasks();
}
process();
