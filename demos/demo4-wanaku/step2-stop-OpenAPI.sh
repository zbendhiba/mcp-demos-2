#!/bin/bash

# Demo 4 - Stop OpenAPI Server with demo-magic
# This script stops the Market Data API server and cleans up

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
p "🛑  Stop OpenAPI Server"
p "=============================="
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

# Step 2: Stop Market Data API Server
p "📋 Step 2: Stopping Market Data API Server..."
SERVER_PID=$(pgrep -f "yfinServer.py" 2>/dev/null)
if [ -n "$SERVER_PID" ]; then
    p "⚠️  Market Data API Server is running (PID: $SERVER_PID)"
    p "🛑 Stopping server..."
    pe "kill -9 $SERVER_PID"
    p "✅ Market Data API Server stopped!"
else
    p "✅ Market Data API Server is not running"
fi
p ""

# Step 3: Check and free port 8000
p "📋 Step 3: Checking port 8000..."
PORT_8000_PID=$(lsof -ti:8000 2>/dev/null)
if [ -n "$PORT_8000_PID" ]; then
    p "⚠️  Found process using port 8000 (PID: $PORT_8000_PID)"
    p "🛑 Freeing port 8000..."
    pe "kill -9 $PORT_8000_PID"
    p "✅ Port 8000 freed!"
else
    p "✅ Port 8000 is already free!"
fi
p ""

# Step 4: Clean up generated files
p "📋 Step 4: Cleaning up generated files..."
if [ -f "generated_tools.json" ]; then
    pe "rm -f generated_tools.json"
    p "✅ Generated tools file removed!"
else
    p "✅ No generated tools file to clean up"
fi

if [ -f "server.log" ]; then
    pe "rm -f server.log"
    p "✅ Server log file removed!"
else
    p "✅ No server log file to clean up"
fi
p ""

# Step 5: Verify cleanup
p "📋 Step 5: Verifying cleanup..."
pe "ps aux | grep yfinServer | grep -v grep"
p "🔍 Checking port 8000..."
pe "lsof -ti:8000 || echo 'Port 8000 is free'"
p "✅ Cleanup verification completed!"
p ""

# Step 6: Show cleanup summary
p "📋 Cleanup Summary:"
p "• Claude Desktop has been stopped"
p "• Market Data API Server has been stopped"
p "• Port 8000 is now free"
p "• Generated files have been cleaned up"
p ""

p "🎉 Demo 4 cleanup completed! Market Data API Server has been stopped."
