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

CLIENT_ORIGIN = "*"


class OpsStreamHandler(BaseHTTPRequestHandler):
    def _set_sse_headers(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "keep-alive")
        self.send_header("Access-Control-Allow-Origin", CLIENT_ORIGIN)
        self.end_headers()

    def do_GET(self):
        print("[OPS_STREAM] do_GET called with path:", self.path)
        sys.stdout.flush()

        if self.path != "/events/ops":
            self.send_response(404)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"Not Found\n")
            return

        self._set_sse_headers()

        try:
            first_payload = {
                "type": "ops_stream_connected",
                "message": "OPS SSE connection established",
            }
            first_str = (
                'data: {"type":"ops_stream_connected","message":"OPS SSE connection established"}\n\n'
            )
            self.wfile.write(first_str.encode("utf-8"))
            self.wfile.flush()
            print("[OPS_STREAM] Sent initial ops_stream_connected event")
            sys.stdout.flush()
        except Exception as e:
            print("[OPS_STREAM] Error sending initial event:", repr(e))
            sys.stdout.flush()
            return

        counter = 0
        try:
            while True:
                json_str = (
                    '{"type":"ops_heartbeat","sequence":%d,"message":"Ops stream alive"}'
                    % counter
                )
                message = f"data: {json_str}\n\n"
                try:
                    self.wfile.write(message.encode("utf-8"))
                    self.wfile.flush()
                    print(
                        "[OPS_STREAM] Sent heartbeat sequence",
                        counter,
                        "to",
                        self.client_address,
                    )
                    sys.stdout.flush()
                except (BrokenPipeError, ConnectionResetError) as e:
                    print("[OPS_STREAM] Client disconnected:", repr(e))
                    sys.stdout.flush()
                    break
                except Exception as e:
                    print("[OPS_STREAM] Error writing heartbeat:", repr(e))
                    sys.stdout.flush()
                    break

                counter += 1
                time.sleep(1)
        except Exception as outer_e:
            print("[OPS_STREAM] Outer loop error:", repr(outer_e))
            sys.stdout.flush()

    def log_message(self, format, *args):
        sys.stdout.write(
            "[OPS_STREAM_LOG] %s - - [%s] %s\n"
            % (self.client_address[0], self.log_date_time_string(), format % args)
        )
        sys.stdout.flush()


def run_server(port: int):
    print(
        f"🔌 Ops Stream SSE server starting at http://localhost:{port}/events/ops"
    )
    sys.stdout.flush()
    server = HTTPServer(("", port), OpsStreamHandler)
    print(
        f"🔌 Ops Stream SSE server listening at http://localhost:{port}/events/ops"
    )
    sys.stdout.flush()
    server.serve_forever()


def main():
    if len(sys.argv) != 3 or sys.argv[2] != "--serve":
        print("Usage: ops_stream.py <port> --serve")
        sys.exit(1)

    port = int(sys.argv[1])
    run_server(port)


if __name__ == "__main__":
    main()
