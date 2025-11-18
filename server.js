import bodyParser from "body-parser";
import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { exec } from "child_process";
import fs from "fs";
import fetch from "node-fetch";

// Setup __dirname and __filename for ES Module compatibility
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// --- Core Server Setup ---
const PORT = process.env.PORT || 3000;
const app = express();

// Middleware (One Declaration Rule)
app.use(express.json()); // Use express's built-in JSON parser
app.use(express.static(path.join(__dirname, "ui/dashboard")));
app.use(express.static(path.join(__dirname, "public")));

const LOG_FILE_PATH = path.join(__dirname, "ui/dashboard/ticker-events.log");

// --- 1️⃣ Agent Status via PM2 (Consolidated Try/Catch) ---
app.get("/api/agent-status", (req, res) => {
    exec("pm2 jlist", (err, stdout) => {
        // If PM2 command fails
        if (err) {
            console.error("PM2 jlist error:", err.message);
            return res.status(500).json({ Matilda: { status: "offline" }, Cade: { status: "offline" }, Effie: { status: "offline" } });
        }

        try {
            const list = JSON.parse(stdout);
            const statusMap = { Matilda: { status: "offline" }, Cade: { status: "offline" }, Effie: { status: "offline" } };

            list.forEach(proc => {
                const name = proc.name.toLowerCase();
                const online = proc.pm2_env.status === "online";
                
                // Map PM2 processes to the three core agents
                if (name.includes("matilda")) statusMap.Matilda.status = online ? "online" : "offline";
                if (name.includes("cade")) statusMap.Cade.status = online ? "online" : "offline";
                if (name.includes("effie")) statusMap.Effie.status = online ? "online" : "offline";
            });
            
            res.json(statusMap);
        } catch (parseError) {
            console.error("Error parsing PM2 jlist output:", parseError.message);
            // Fallback response on JSON parsing failure
            res.status(500).json({ Matilda: { status: "offline" }, Cade: { status: "offline" }, Effie: { status: "offline" } });
        }
    });
});

// --- 2️⃣ Chat Endpoint: Send input to Ollama and Log (Cleaned and Stabilized) ---
app.post("/api/chat", async (req, res) => {
    const userMessage = req.body?.message?.trim() || "";
    console.log("📩 Chat received:", userMessage);
    
    if (!userMessage) return res.json({ reply: "(Please provide a message)" });

    try {
        // 1. Call local Ollama server
        const response = await fetch("http://127.0.0.1:11434/api/generate", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ model: "llama3:8b", prompt: userMessage, stream: false })
        });

        const data = await response.json();
        const reply = data.response?.trim() || "(no response)";

        // 2. Return reply to dashboard
        res.json({ reply });
        
        // 3. Log chat interaction (Cleaned Multi-line Logging)
        const logEntry = { 
            timestamp: Math.floor(Date.now() / 1000), 
            agent: "matilda", 
            event: `chat: ${userMessage.substring(0, 50)}... -> ${reply.substring(0, 50)}...` 
        };
        fs.appendFileSync(LOG_FILE_PATH, JSON.stringify(logEntry) + '\n');
        
    } catch (err) {
        console.error("❌ Chat/Ollama error:", err.message);
        // Ensure error is logged to console and a safe response is sent
        res.status(500).json({ reply: "(Matilda is thinking... or disconnected)" });
    }
});

// --- 3️⃣ Task Delegation Endpoint (Consolidated) ---
app.post("/tasks/delegate", (req, res) => {
    const taskDetails = req.body;
    console.log("📥 Delegate POST received:", taskDetails);
    
    // Log delegation event
    try {
        const logEntry = { 
            timestamp: Math.floor(Date.now() / 1000), 
            agent: "matilda", 
            event: `delegated: Task ${taskDetails.taskId || 'new'} acknowledged`
        };
        fs.appendFileSync(LOG_FILE_PATH, JSON.stringify(logEntry) + '\n');
    } catch (logErr) {
        console.error("Error logging delegation:", logErr.message);
    }
    
    // Respond to client
    res.json({ status: "ok", taskId: taskDetails.taskId || Date.now() });
});


app.get("/api/ops-stream", (req, res) => {
    const logFile = path.join(__dirname, "ui/dashboard/ticker-events.log");
    
    if (!fs.existsSync(logFile)) return res.json([]);
    
    // Reading the last 20 log lines safely
    try {
        const fileContent = fs.readFileSync(logFile, 'utf8');
        const lines = fileContent.trim().split('\n').slice(-20);
        const events = lines.map(line => {
             try {
                 const obj = JSON.parse(line);
                 return { message: `${obj.agent} | ${obj.event}` };
             } catch {
                 return { message: line };
             }
        });
        res.json(events);
    } catch(err) {
        console.error("Error reading ops-stream log:", err);
        res.status(500).json({ message: "Error reading logs." });
    }
});


// --- Server Listener ---
app.listen(PORT, () => console.log(`✅ Dashboard live on port ${PORT}`));

// --- 5️⃣ Agent Status Stream (SSE) ---
app.get("/api/agent-status-stream", (req, res) => {
    // Set headers for SSE
    res.writeHead(200, {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        "Connection": "keep-alive",
    });

    const sendStatus = () => {
        exec("pm2 jlist", (err, stdout) => {
            let statusData = { Matilda: { status: "offline" }, Cade: { status: "offline" }, Effie: { status: "offline" } };
            
            if (!err) {
                try {
                    const list = JSON.parse(stdout);
                    list.forEach(proc => {
                        const name = proc.name.toLowerCase();
                        const online = proc.pm2_env.status === "online";
                        if (name.includes("matilda")) statusData.Matilda.status = online ? "online" : "offline";
                        if (name.includes("cade")) statusData.Cade.status = online ? "online" : "offline";
                        if (name.includes("effie")) statusData.Effie.status = online ? "online" : "offline";
                    });
                } catch (e) {
                    console.error("SSE PM2 Parse Error:", e.message);
                }
            }
            
            // Send the data as an SSE message
            res.write(`data: ${JSON.stringify(statusData)}\n\n`);
        });
    };

    // Send status immediately and then every 3 seconds
    sendStatus();
    const intervalId = setInterval(sendStatus, 3000);

    // Clear interval and close connection when client disconnects
    req.on("close", () => {
        clearInterval(intervalId);
        res.end();
    });
});

// --- 6️⃣ Reflection Log Stream (SSE) on /api/reflection-stream ---
app.get("/api/reflection-stream", (req, res) => {
    // Set headers for SSE
    res.writeHead(200, {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        "Connection": "keep-alive",
    });

    const logFile = path.join(__dirname, "ui/dashboard/ticker-events.log");
    
    // Function to send the latest log line
    const sendUpdate = (data) => {
        // Assume data is the new content added to the log file (usually the last line)
        if (data) {
            const line = data.toString().trim();
            if (line) {
                let eventData = { message: line };
                try {
                    // Try to parse the JSON log entry for structured data
                    const obj = JSON.parse(line);
                    eventData = { message: `${obj.agent} | ${obj.event}` };
                } catch (e) {
                    // If not JSON, send as raw line
                }
                res.write(`data: ${JSON.stringify(eventData)}\n\n`);
            }
        }
    };

    // Watch the log file for changes
    const watcher = fs.watch(logFile, (eventType, filename) => {
        if (eventType === 'change') {
            // Re-read the file to get the new line (less efficient, but safer for simplicity)
            // A more robust solution involves tracking file size, but this works for simple append-only logs.
            try {
                const content = fs.readFileSync(logFile, 'utf8');
                const lastLine = content.trim().split('\n').pop();
                sendUpdate(lastLine);
            } catch (e) {
                console.error("Error reading log file during watch:", e.message);
            }
        }
    });

    // Handle client disconnect
    req.on("close", () => {
        watcher.close();
        res.end();
        console.log("Reflection stream client disconnected.");
    });
    
    // Optional: Send a dummy heartbeat to initialize the connection
    res.write('data: {"message": "Reflection stream initialized"}\n\n');
});

