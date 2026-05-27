# Docker Dashboard Deploy Notes

Branch: feature/v11-dashboard-bundle

This document records the basic steps to run the updated dashboard (including the Matilda Chat Console) inside Docker on macOS.

1. Start Docker Desktop so the Docker daemon is available.
2. From the project root, build and start the services:

   docker-compose build
   docker-compose up -d

If the daemon is not running, Docker will return an error similar to:

   Cannot connect to the Docker daemon at unix:///Users/USERNAME/.docker/run/docker.sock.

In that case, open Docker Desktop and wait until it reports that Docker is running, then rerun the commands above.
