import time
import os

print("Reflections Stream initializing...")

# Replace 'postgres' with the Docker service name
DB_HOST = os.environ.get('PG_HOST', 'postgres')
DB_NAME = os.environ.get('DB_NAME', 'motherboard_db')

print(f"Attempting to connect to database at {DB_HOST}/{DB_NAME}...")

# Simple loop to simulate a long-running stream process
while True:
    print("Reflections Stream is running and collecting data...")
    time.sleep(60)
