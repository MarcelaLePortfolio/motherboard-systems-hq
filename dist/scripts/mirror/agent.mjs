/**
 * Mirror Agent stub with HTTP heartbeat on fixed ports + all-path response
 */
import http from "http";
const PORT_MAP = {
    cade: 3012,
    effie: 3013,
};
export function createAgentRuntime(agent) {
    const name = agent?.name?.toLowerCase() || "agent";
    const port = PORT_MAP[name] || 0;
    console.log(`Mirror stub: Launching agent runtime for ${name} on port ${port || "no-port"}`);
    // Heartbeat log to keep process alive
    setInterval(() => {
        console.log(` ${name} heartbeat...`);
    }, 10000);
    if (port) {
        http.createServer((req, res) => {
            // Respond OK for any path
            res.writeHead(200, { "Content-Type": "application/json" });
            res.end(JSON.stringify({ status: "online", agent: name, path: req.url }));
        }).listen(port, () => {
            console.log(` ${name} stub server listening on port ${port}`);
        });
    }
}
