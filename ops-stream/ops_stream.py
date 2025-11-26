#!/usr/bin/env python3
"""
Ops Stream SSE server.

Usage:
    python3 ops-stream/ops_stream.py 3201 --serve

Serves a Server-Sent Events stream at:
    GET /events/ops
"""

import sys
import time
from http.server import HTTPServer, BaseHTTPRequestHandler

CORS_ALLOW_ORIGIN = "*"


class OpsStreamHandler(BaseHTTPRequestHandler):
    def _set_sse_headers(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "keep-alive")
        self.send_header("Access-Control-Allow-Origin", CORS_ALLOW_ORIGIN)
        self.end_headers()

    def do_GET(self):
        if self.path != "/events/ops":
            self.send_response(404)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"Not Found\n")
            return

        self._set_sse_headers()

        counter = 0
        try:
            while True:
                json_str = (
                    '{"type":"ops_heartbeat","sequence":%d,"message":"Ops stream alive"}'
                    % counter
                )
                message = f"data: {json_str}\n\n"
                self.wfile.write(message.encode("utf-8"))
                self.wfile.flush()

                counter += 1
                time.sleep(1)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def log_message(self, format, *args):
        sys.stdout.write(
            "[OPS_STREAM] %s - - [%s] %s\n"
            % (self.client_address[0], self.log_date_time_string(), format % args)
        )


def run_server(port: int):
    server = HTTPServer(("", port), OpsStreamHandler)
    print(f"🔌 Ops Stream SSE server listening at http://localhost:{port}/events/ops")
    server.serve_forever()


def main():
    if len(sys.argv) != 3 or sys.argv[2] != "--serve":
        print("Usage: ops_stream.py <port> --serve")
        sys.exit(1)

    port = int(sys.argv[1])
    run_server(port)


if __name__ == "__main__":
    main()
