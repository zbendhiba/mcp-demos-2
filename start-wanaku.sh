#!/bin/bash

# Wanaku Demo Script with demo-magic
# This script demonstrates the complete Wanaku setup process

########################
# include the magic
########################
# Demo-magic functions integrated directly
DEMO_PROMPT="$ "
DEMO_CMD_COLOR=$GREEN
DEMO_COMMENT_COLOR=$YELLOW
DEMO_SPEED=50

# Demo-magic functions
p() {
    echo -e "\033[1;32m$@\033[0m"
    sleep 1
}

pe() {
    echo -e "\033[1;32m$@\033[0m"
    sleep 1
    eval "$@"
}

pei() {
    echo -e "\033[1;32m$@\033[0m"
    sleep 1
    eval "$@" > /dev/null 2>&1
}

wait() {
    echo -e "\033[1;33mPress any key to continue...\033[0m"
    read -n 1
}

# Change to wanaku directory
cd "$(dirname "$0")/wanaku" || exit 1

# Clear screen and start demo
clear
p "🚀 Wanaku Container Management Demo"
p "=================================="
p ""

# Step 1: Stop and clean existing containers
p "📋 Step 1: Stopping and cleaning existing containers..."
pe "./stop-and-cleanup.sh"
p "✅ Cleanup completed!"
p ""

# Step 2: Start containers with docker-compose
p "📋 Step 2: Starting containers with docker-compose..."
pe "docker-compose up -d"
p "✅ Containers started!"
p ""

# Step 3: Wait a moment for containers to initialize
p "⏳ Waiting for containers to initialize..."
pe "sleep 10"
p ""

# Step 4: Check containers with podman ps
p "📋 Step 3: Verifying containers are running with podman ps..."
pe "podman ps"
p "✅ All containers are running!"
p ""

# Step 5: Check if services registered themselves
p "📋 Step 4: Checking if services registered themselves with Wanaku..."
pe "wanaku targets tools list"
p ""

# Step 6: Show additional useful commands
p "📋 Additional useful commands:"
p "• View logs: docker-compose logs -f"
p "• Check status: docker-compose ps"
p "• Stop services: docker-compose down"
p "• Restart services: docker-compose restart"
p ""

p "🎉 Demo completed! Wanaku is ready to use."
