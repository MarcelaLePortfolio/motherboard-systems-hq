export async function cadeCommandRouter(action, options) {
    switch(action) {
        case "install deps": {
            const { default: handler } = await import("./handlers/installDepsHandler.js");
            return handler(options);
        }
        case "run script": {
            const { default: handler } = await import("./handlers/runScriptHandler.js");
            return handler(options);
        }
        case "start agent": {
            const { default: handler } = await import("./handlers/startAgentHandler.js");
            return handler(options);
        }
        case "report status": {
            const { default: handler } = await import("./handlers/reportStatusHandler.js");
            return handler(options);
        }
        case "zip backup": {
            const { default: handler } = await import("./handlers/zipBackupHandler.js");
            return handler(options);
        }
        case "infer agent": {
            const { default: handler } = await import("./handlers/inferAgentHandler.js");
            return handler(options);
        }
        default:
            return { error: 'Unknown action' };
    }
}
