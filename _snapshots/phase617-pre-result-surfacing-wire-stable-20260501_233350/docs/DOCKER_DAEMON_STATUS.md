# Docker Daemon Status – Matilda Chat Console Container Deploy

Branch: feature/v11-dashboard-bundle

Current situation:

- Dashboard code (including Matilda Chat Console) is committed and pushed.
- Attempted to run:
  - docker-compose build
  - docker-compose up -d
- Docker error returned:
  - "Cannot connect to the Docker daemon at unix:///Users/marcela-dev/.docker/run/docker.sock. Is the docker daemon running?"

Interpretation:

- The Docker daemon is not running on macOS.
- The dashboard container cannot be built or started until Docker Desktop finishes starting and the daemon is available.

Action steps for deployment:

1. Start Docker Desktop:

   - Either click Docker Desktop in the Applications folder or run:
     - open -a Docker

2. Wait until Docker Desktop reports "Docker is running" in the menu bar.

3. From the project root, run:

   docker-compose build
   docker-compose up -d

Once those commands succeed, the containerized dashboard will include:

- public/index.html with:
  - <script defer src="js/matilda-chat-console.js"></script>
- public/js/matilda-chat-console.js with the visible Matilda Chat Console under the header.
