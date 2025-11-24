import time
import os

print("Ops Stream initializing...")

# Replace 'postgres' with the Docker service name (which works as the hostname)
DB_HOST = os.environ.get('PG_HOST', 'postgres')
DB_NAME = os.environ.get('DB_NAME', 'motherboard_db')

print(f"Attempting to connect to database at {DB_HOST}/{DB_NAME}...")

# Simple loop to simulate a long-running stream process
while True:
    print("Ops Stream is running and waiting for data...")
    time.sleep(30)
