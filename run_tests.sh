#!/bin/bash
echo "Waiting for services..."
docker compose exec dashboard /usr/bin/npm test

