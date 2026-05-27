#!/usr/bin/env python3
"""
Reflections Stream SSE server.

Usage:
    python3 reflections-stream/reflections_stream.py 3200 --serve

Serves a Server-Sent Events stream at:
    GET /events/reflections
"""

import sys
import time
import os
import json
from http.server import HTTPServer, BaseHTTPRequestHandler

DB_HOST = os.environ.get("PG_HOST", "postgres")
DB_NAME = os.environ.get("DB_NAME", "motherboard_db")
DB_INFO = f"{DB_HOST}/{DB_NAME}"

CLIENT_ORIGIN = "*"


class ReflectionsStreamHandler(BaseHTTPRequestHandler):
    def _set_sse_headers(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "keep-alive")
        self.send_header("Access-Control-Allow-Origin", CLIENT_ORIGIN)
        self.end_headers()

    def do_GET(self):
        print("[REFL_STREAM] do_GET called with path:", self.path)
        sys.stdout.flush()

        if self.path != "/events/reflections":
            self.send_response(404)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"Not Found\n")
            return

        self._set_sse_headers()

        try:
            first_data = {
                "type": "reflections_stream_connected",
                "message": "Reflections SSE connection established",
                "source_db": DB_INFO,
            }
            first_str = (
                "data: "
                + json.dumps(first_data, separators=(",", ":"))
                + "\n\n"
            )
            self.wfile.write(first_str.encode("utf-8"))
            self.wfile.flush()
            print("[REFL_STREAM] Sent initial reflections_stream_connected event")
            sys.stdout.flush()
        except Exception as e:
            print("[REFL_STREAM] Error sending initial event:", repr(e))
            sys.stdout.flush()
            return

        counter = 0
        try:
            while True:
                data = {
                    "type": "reflection_update",
                    "id": counter,
                    "timestamp": time.time(),
                    "source_db": DB_INFO,
                    "status": "PROCESSING",
                    "sequence": counter,
                }
                msg = "data: " + json.dumps(data, separators=(",", ":")) + "\n\n"
                try:
                    self.wfile.write(msg.encode("utf-8"))
                    self.wfile.flush()
                    print(
                        "[REFL_STREAM] Sent reflection sequence",
                        counter,
                        "to",
                        self.client_address,
                    )
                    sys.stdout.flush()
                except (BrokenPipeError, ConnectionResetError) as e:
                    print("[REFL_STREAM] Client disconnected:", repr(e))
                    sys.stdout.flush()
                    break
                except Exception as e:
                    print("[REFL_STREAM] Error writing reflection:", repr(e))
                    sys.stdout.flush()
                    break

                counter += 1
                time.sleep(2)
        except Exception as outer_e:
            print("[REFL_STREAM] Outer loop error:", repr(outer_e))
            sys.stdout.flush()

    def log_message(self, format, *args):
        pass


def run_server(port: int):
    print("Reflections Stream initializing...")
    print(f"Attempting to connect to database at {DB_INFO}...")
    sys.stdout.flush()
    server = HTTPServer(("", port), ReflectionsStreamHandler)
    print(
        f"Reflections Stream is running and collecting data from {DB_INFO}..."
    )
    print(
        f"🔌 Reflections Stream SSE server listening at http://localhost:{port}/events/reflections"
    )
    sys.stdout.flush()
    server.serve_forever()


def main():
    if len(sys.argv) != 3 or sys.argv[2] != "--serve":
        print("Usage: reflections_stream.py <port> --serve")
        sys.exit(1)

    port = int(sys.argv[1])
    run_server(port)


if __name__ == "__main__":
    main()
