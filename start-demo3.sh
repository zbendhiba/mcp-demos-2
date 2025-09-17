#!/bin/bash

# Demo 3 - Quarkus MCP Web Server Setup with demo-magic
# This script demonstrates setting up the Quarkus MCP Web server for Claude Desktop

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
p "🌐 Demo 3: Quarkus MCP Web Server Setup"
p "======================================"
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

# Step 2: Start Quarkus MCP Web Server
p "📋 Step 2: Starting Quarkus MCP Web Server..."
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR/demos/demo3-mcp-server-web"
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
    pe "sleep 10"
    # Check if any process is still running
    REMAINING_PIDS=$(lsof -ti:8081 2>/dev/null)
    if [ -n "$REMAINING_PIDS" ]; then
        p "⚠️  Some processes still running (PIDs: $REMAINING_PIDS), force killing..."
        for pid in $REMAINING_PIDS; do
            pe "kill -9 $pid 2>/dev/null || true"
        done
        p "⏳ Waiting longer for processes to terminate..."
        pe "sleep 10"
        # Final check
        FINAL_PIDS=$(lsof -ti:8081 2>/dev/null)
        if [ -n "$FINAL_PIDS" ]; then
            p "❌ Port 8081 still in use after multiple attempts (PIDs: $FINAL_PIDS)"
            p "Please manually kill the processes using: sudo lsof -ti:8081 | xargs kill -9"
            exit 1
        fi
    fi
    p "✅ Port 8081 freed!"
else
    p "✅ Port 8081 is free!"
fi

# Clean up log files
p "🧹 Cleaning up log files..."
if [ -d "logs" ]; then
    pe "rm -rf logs/*"
    p "✅ Log files cleaned!"
else
    p "ℹ️  No logs directory found"
fi
# Final check that port is free
if lsof -ti:8081 >/dev/null 2>&1; then
    p "❌ Port 8081 is still in use, cannot start Quarkus server"
    p "Please manually kill the process using: sudo lsof -ti:8081 | xargs kill -9"
    exit 1
fi

p "🚀 Starting Quarkus development server..."
pe "./mvnw quarkus:dev &"
QUARKUS_PID=$!
p "✅ Quarkus server started (PID: $QUARKUS_PID)!"
p "⏳ Waiting for server to initialize..."
pe "sleep 10"
p ""

# Step 3: Check if the server is running
p "📋 Step 3: Verifying Quarkus server is running..."
pe "curl -s http://localhost:8081/health || echo 'Server not ready yet'"
p ""

# Step 4: Create Claude Desktop config directory if it doesn't exist
p "📋 Step 4: Ensuring Claude Desktop config directory exists..."
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
pe "mkdir -p '$CLAUDE_CONFIG_DIR'"
p "✅ Config directory ready!"
p ""

# Step 5: Backup existing config if it exists
p "📋 Step 5: Backing up existing configuration..."
TARGET_CONFIG="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
if [ -f "$TARGET_CONFIG" ]; then
    BACKUP_FILE="$TARGET_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    pe "cp '$TARGET_CONFIG' '$BACKUP_FILE'"
    p "✅ Existing config backed up to: $BACKUP_FILE"
else
    p "ℹ️  No existing config file to backup"
fi
p ""

# Step 6: Generate and copy the Quarkus MCP Web configuration
p "📋 Step 6: Installing Quarkus MCP Web server configuration..."
p "🔍 Generating configuration for MCP Web server..."
echo "{
    \"mcpServers\": {
      \"demo3-mcp-server\": {
        \"command\": \"uvx\",
        \"args\": [
          \"mcp-proxy\",
          \"http://localhost:8081/mcp/sse\"
        ]
      }
  }
}" > "$TARGET_CONFIG"
p "✅ Configuration generated and copied successfully!"
p ""

# Step 7: Verify the installation
p "📋 Step 7: Verifying the installation..."
pe "cat '$TARGET_CONFIG'"
p "✅ Configuration verified!"
p ""

# Step 8: Start Claude Desktop
p "📋 Step 8: Starting Claude Desktop..."
pe "/Applications/Claude.app/Contents/MacOS/Claude &"
p "✅ Claude Desktop started!"
p ""

# Step 9: Start MCP Inspector
p "📋 Step 9: Starting MCP Inspector..."
p "🛑 Stopping any existing MCP Inspector and freeing ports..."
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
p "🔍 Launching MCP Inspector for Streamable connection..."
pe "osascript -e 'tell application \"Terminal\" to do script \"cd $(pwd) && npx @modelcontextprotocol/inspector --streamable http://localhost:8081/mcp/\"'"
p "✅ MCP Inspector started with Streamable connection!"
p ""

# Step 10: Show next steps
p "📋 Next steps:"
p "• Claude Desktop should now have access to the Quarkus MCP Web server"
p "• You can test the connection by asking Claude to use the greet prompt"
p "• The MCP server provides greeting functionality via web interface"
p "• MCP Inspector is running with Streamable connection to http://localhost:8081/mcp/"
p ""

p "🎉 Demo 3 setup completed! Quarkus MCP Web server is now configured in Claude Desktop."
p ""
p "Use the following prompt in Claude Desktop: Try the greet function with a name"
p ""
p "Check the MCP Inspector to see the capabilities of the Quarkus MCP Web server"
p "The server is running at: http://localhost:8081/mcp/"
