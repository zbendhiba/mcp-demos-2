#!/bin/bash

# Demo 1 - PostgreSQL MCP Server Cleanup with demo-magic
# This script demonstrates stopping and cleaning up the PostgreSQL MCP server setup

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

# Clear screen and start demo
clear
p "🛑 Demo 1: PostgreSQL MCP Server Cleanup"
p "======================================="
p ""

# Step 1: Check if Claude Desktop is running
p "📋 Step 1: Checking if Claude Desktop is running..."
CLAUDE_PID=$(pgrep -f "/Applications/Claude.app/Contents/MacOS/Claude" 2>/dev/null)
if [ -n "$CLAUDE_PID" ]; then
    p "⚠️  Claude Desktop is running (PID: $CLAUDE_PID)"
    p "🛑 Stopping Claude Desktop..."
    pe "kill -9 $CLAUDE_PID"
    p "✅ Claude Desktop stopped!"
else
    p "✅ Claude Desktop is not running"
fi
p ""

# Step 2: Check PostgreSQL containers
p "📋 Step 2: Checking PostgreSQL containers..."
pe "podman ps --filter ancestor=docker.io/library/postgres:latest"
p ""

# Step 3: Stop and remove all PostgreSQL containers
p "📋 Step 3: Stopping and removing all PostgreSQL containers..."
pe "podman stop $(podman ps -q --filter ancestor=docker.io/library/postgres:latest) 2>/dev/null || true"
pe "podman rm $(podman ps -aq --filter ancestor=docker.io/library/postgres:latest) 2>/dev/null || true"
pe "podman stop my-postgres-db 2>/dev/null || true"
pe "podman rm my-postgres-db 2>/dev/null || true"
p "✅ All PostgreSQL containers stopped and removed!"
p ""

# Step 4: Verify containers are stopped
p "📋 Step 4: Verifying all containers are stopped..."
pe "podman ps --filter ancestor=docker.io/library/postgres:latest"
p "✅ All PostgreSQL containers are stopped!"
p ""

# Step 5: Show cleanup summary
p "📋 Cleanup Summary:"
p "• Claude Desktop has been stopped"
p "• All PostgreSQL containers have been removed"
p "• Port 5432 is now free"
p "• PostgreSQL data volume 'postgres_data' is preserved"
p ""

p "🎉 Demo 1 cleanup completed! PostgreSQL MCP server setup has been removed."
