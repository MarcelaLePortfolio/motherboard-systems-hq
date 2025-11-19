#!/bin/bash
# Wait for the dashboard service to become ready by checking its exposed port.
# If the service takes a moment to initialize, this loop handles it.
echo "Waiting for dashboard service to be ready..."
for i in {1..20}; do
    docker compose ps | grep dashboard | grep running && break
    echo "Attempt $i/20: Dashboard service not yet running. Waiting 3 seconds..."
    sleep 3
done

# Execute the tests inside the running "dashboard" container
echo "Executing tests..."
docker compose exec dashboard /usr/bin/npm test

