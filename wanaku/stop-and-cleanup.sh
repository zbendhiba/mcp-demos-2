#!/bin/bash

# Wanaku Container Management Script
# This script stops and removes all Wanaku containers and their associated resources
# Uses docker-compose for orchestration and podman for individual container operations

echo "🛑 Stopping and cleaning up Wanaku containers..."

# Stop and remove all containers defined in docker-compose.yml
echo "📦 Stopping containers with docker-compose..."
docker-compose down

# Remove any remaining containers with wanaku- prefix (in case some weren't managed by compose)
echo "🧹 Removing any remaining Wanaku containers..."
podman stop $(podman ps -q --filter "name=wanaku-") 2>/dev/null || true
podman rm $(podman ps -aq --filter "name=wanaku-") 2>/dev/null || true

# Optional: Remove associated volumes (uncomment if you want to remove data)
# echo "🗑️  Removing associated volumes..."
# podman volume prune -f

# Optional: Remove associated networks (uncomment if you want to remove networks)
# echo "🌐 Removing associated networks..."
# podman network prune -f

echo "✅ Cleanup complete!"
echo ""
echo "To start the services again, run:"
echo "  docker-compose up -d"
echo ""
echo "To see running containers, run:"
echo "  podman ps"
