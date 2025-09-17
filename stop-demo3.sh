#!/bin/bash

# Demo 3 - Quarkus MCP Web Server Cleanup with demo-magic
# This script demonstrates stopping and cleaning up the Quarkus MCP Web server setup

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
p "🛑 Demo 3: Quarkus MCP Web Server Cleanup"
p "========================================="
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

# Step 2: Stop Quarkus MCP Web Server
p "📋 Step 2: Stopping Quarkus MCP Web Server..."
p "🛑 Checking and freeing port 8081..."
PORT_8081_PIDS=$(lsof -ti:8081 2>/dev/null)
if [ -n "$PORT_8081_PIDS" ]; then
    p "⚠️  Found processes using port 8081 (PIDs: $PORT_8081_PIDS)"
    # Kill each PID individually
    for pid in $PORT_8081_PIDS; do
        p "🛑 Killing process $pid..."
        pe "kill -9 $pid 2>/dev/null || true"
    done
    p "⏳ Waiting for processes to terminate..."
    pe "sleep 5"
    # Check if any process is still running
    REMAINING_PIDS=$(lsof -ti:8081 2>/dev/null)
    if [ -n "$REMAINING_PIDS" ]; then
        p "⚠️  Some processes still running (PIDs: $REMAINING_PIDS), force killing..."
        for pid in $REMAINING_PIDS; do
            pe "kill -9 $pid 2>/dev/null || true"
        done
        pe "sleep 3"
    fi
    p "✅ Port 8081 freed!"
else
    p "✅ Port 8081 is free!"
fi
p ""

# Step 3: Stop MCP Inspector
p "📋 Step 3: Stopping MCP Inspector..."
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

# Step 4: Clean up log files
p "📋 Step 4: Cleaning up log files..."
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR/demos/demo3-mcp-server-web"
if [ -d "logs" ]; then
    pe "rm -rf logs/*"
    p "✅ Log files cleaned!"
else
    p "ℹ️  No logs directory found"
fi
p ""

# Step 5: Show cleanup summary
p "📋 Cleanup Summary:"
p "• Claude Desktop has been stopped"
p "• Quarkus MCP Web server has been stopped"
p "• Port 8081 is now free"
p "• MCP Inspector has been stopped"
p "• Ports 6274 and 6275 are now free"
p "• Log files have been cleaned"
p ""

p "🎉 Demo 3 cleanup completed! Quarkus MCP Web server setup has been removed."
