#!/bin/bash

echo "🚀 Starting Wanaku (Simplified)"
echo "================================"

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f wanaku/docker-compose.yml down

# Clean up
echo "🧹 Cleaning up..."
docker system prune -f

# Start only the router first
echo "🚀 Starting Wanaku router..."
docker-compose -f wanaku/docker-compose.yml up wanaku-router -d

# Wait for router to be ready
echo "⏳ Waiting for router to be ready..."
sleep 30

# Check if router is running
if docker ps | grep -q wanaku-router; then
    echo "✅ Wanaku router is running!"
    
    # Start other services
    echo "🚀 Starting other services..."
    docker-compose -f wanaku/docker-compose.yml up -d
    
    echo "🎉 Wanaku is ready!"
    echo "📊 Check status: docker ps"
    echo "🌐 UI available at: http://localhost:8080"
else
    echo "❌ Wanaku router failed to start"
    echo "📋 Check logs: docker logs wanaku-router"
fi
