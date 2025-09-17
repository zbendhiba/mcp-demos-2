#!/bin/bash

# Wanaku Stop Demo Script with demo-magic
# This script demonstrates stopping and cleaning up Wanaku containers

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
p "🛑 Wanaku Container Stop Demo"
p "============================="
p ""

# Step 1: Show current running containers
p "📋 Step 1: Checking current running containers..."
pe "podman ps"
p ""

# Step 2: Stop and clean up containers
p "📋 Step 2: Stopping and cleaning up Wanaku containers..."
p "📦 Stopping containers with docker-compose..."
pe "docker-compose down"
p "🧹 Removing any remaining Wanaku containers..."
pe "podman stop $(podman ps -q --filter 'name=wanaku-') 2>/dev/null || true"
pe "podman rm $(podman ps -aq --filter 'name=wanaku-') 2>/dev/null || true"
p "✅ Cleanup completed!"
p ""

# Step 3: Verify containers are stopped
p "📋 Step 3: Verifying containers are stopped..."
pe "podman ps"
p "✅ All Wanaku containers have been stopped and removed!"
p ""

p "🎉 Demo completed! Wanaku containers have been stopped and cleaned up."
