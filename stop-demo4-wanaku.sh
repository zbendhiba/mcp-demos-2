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
p "🛑 Demo 4: Wanaku Container Stop Demo"
p "===================================="
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

# Step 2: Stop MCP Inspector
p "📋 Step 2: Stopping MCP Inspector..."
# Kill processes using port 6274 (MCP Inspector)
PORT_6274_PID=$(lsof -ti:6274 2>/dev/null)
if [ -n "$PORT_6274_PID" ]; then
    p "⚠️  Found process using port 6274 (PID: $PORT_6274_PID)"
    pe "kill -9 $PORT_6274_PID"
    p "✅ Port 6274 freed!"
fi
# Kill processes using port 6275 (MCP Inspector web console)
PORT_6275_PID=$(lsof -ti:6275 2>/dev/null)
if [ -n "$PORT_6275_PID" ]; then
    p "⚠️  Found process using port 6275 (PID: $PORT_6275_PID)"
    pe "kill -9 $PORT_6275_PID"
    p "✅ Port 6275 freed!"
fi
# Also kill any MCP Inspector processes
INSPECTOR_PID=$(pgrep -f "@modelcontextprotocol/inspector" 2>/dev/null)
if [ -n "$INSPECTOR_PID" ]; then
    p "⚠️  MCP Inspector process found (PID: $INSPECTOR_PID)"
    pe "kill -9 $INSPECTOR_PID"
    p "✅ MCP Inspector process stopped!"
fi
p "✅ All MCP Inspector processes and ports cleaned!"
p ""

# Step 3: Show current running containers
p "📋 Step 3: Checking current running containers..."
pe "podman ps"
p ""

# Step 4: Stop and clean up containers
p "📋 Step 4: Stopping and cleaning up Wanaku containers..."
p "📦 Stopping containers with docker-compose..."
pe "docker-compose down"
p "🧹 Removing any remaining Wanaku containers..."
pe "podman stop $(podman ps -q --filter 'name=wanaku-') 2>/dev/null || true"
pe "podman rm $(podman ps -aq --filter 'name=wanaku-') 2>/dev/null || true"
p "✅ Cleanup completed!"
p ""

# Step 5: Verify containers are stopped
p "📋 Step 5: Verifying containers are stopped..."
pe "podman ps"
p "✅ All Wanaku containers have been stopped and removed!"
p ""

# Step 6: Show cleanup summary
p "📋 Cleanup Summary:"
p "• Claude Desktop has been stopped"
p "• MCP Inspector has been stopped"
p "• Ports 6274 and 6275 are now free"
p "• All Wanaku containers have been stopped and removed"
p ""

p "🎉 Demo 4 cleanup completed! Wanaku setup has been removed."
