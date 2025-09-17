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
p "🚀 Demo 4: Wanaku Container Management Demo"
p "=========================================="
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

# Step 3: Stop and clean existing containers
p "📋 Step 3: Stopping and cleaning existing containers..."
p "📦 Stopping containers with docker-compose..."
pe "docker-compose down"
p "🧹 Removing any remaining Wanaku containers..."
pe "podman stop $(podman ps -q --filter 'name=wanaku-') 2>/dev/null || true"
pe "podman rm $(podman ps -aq --filter 'name=wanaku-') 2>/dev/null || true"
p "✅ Cleanup completed!"
p ""

# Step 4: Check and kill processes on port 8080
p "📋 Step 4: Checking for processes using port 8080..."
PORT_8080_PID=$(lsof -ti:8080 2>/dev/null)
if [ -n "$PORT_8080_PID" ]; then
    p "⚠️  Found process(es) using port 8080: $PORT_8080_PID"
    pe "kill -9 $PORT_8080_PID"
    p "✅ Process(es) killed!"
else
    p "✅ Port 8080 is free!"
fi
p ""

# Step 5: Start containers with docker-compose
p "📋 Step 5: Starting containers with docker-compose..."
pe "docker-compose up -d"
p "✅ Containers started!"
p ""

# Step 6: Wait a moment for containers to initialize
p "⏳ Waiting for containers to initialize..."
pe "sleep 10"
p ""

# Step 7: Check containers with podman ps
p "📋 Step 7: Verifying containers are running with podman ps..."
pe "podman ps"
p "✅ All containers are running!"
p ""

# Step 8: Check if services registered themselves
p "📋 Step 8: Checking if services registered themselves with Wanaku..."
pe "wanaku capabilities list"
p ""


# Step 9: Create Claude Desktop config directory if it doesn't exist
p "📋 Step 9: Ensuring Claude Desktop config directory exists..."
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
pe "mkdir -p '$CLAUDE_CONFIG_DIR'"
p "✅ Config directory ready!"
p ""

# Step 10: Backup existing config if it exists
p "📋 Step 10: Backing up existing configuration..."
TARGET_CONFIG="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
if [ -f "$TARGET_CONFIG" ]; then
    BACKUP_FILE="$TARGET_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    pe "cp '$TARGET_CONFIG' '$BACKUP_FILE'"
    p "✅ Existing config backed up to: $BACKUP_FILE"
else
    p "ℹ️  No existing config file to backup"
fi
p ""

# Step 11: Generate and copy the Quarkus MCP Web configuration
p "📋 Step 11: Installing Quarkus MCP Web server configuration..."
p "🔍 Generating configuration for MCP Web server..."
echo "{
    \"mcpServers\": {
      \"demo4-wanaku\": {
        \"command\": \"uvx\",
        \"args\": [
          \"mcp-proxy\",
          \"http://localhost:8080/mcp/sse\"
        ]
      }
  }
}" > "$TARGET_CONFIG"
p "✅ Configuration generated and copied successfully!"
p ""



# Step 12: Verify the installation
p "📋 Step 12: Verifying the installation..."
pe "cat '$TARGET_CONFIG'"
p "✅ Configuration verified!"
p ""

# Step 13: Start Claude Desktop
p "📋 Step 13: Starting Claude Desktop..."
pe "/Applications/Claude.app/Contents/MacOS/Claude &"
p "✅ Claude Desktop started!"
p ""

# Step 14: Start MCP Inspector
p "📋 Step 14: Starting MCP Inspector..."
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
pe "osascript -e 'tell application \"Terminal\" to do script \"cd $(pwd) && npx @modelcontextprotocol/inspector\"'"
p "✅ MCP Inspector started with Streamable connection!"
p ""

# Step 15: Show next steps
p "📋 Next steps:"
p "• Claude Desktop should now have access to the Wanaku MCP server"
p "• You can test the connection by asking Claude to use Wanaku capabilities"
p "• The MCP server provides container management functionality via web interface"
p "• MCP Inspector is running with Streamable connection to http://localhost:8080/mcp/sse"
p ""


# Step 16: Show additional useful commands
p "📋 Additional useful commands:"
p "• View logs: docker-compose logs -f"
p "• Check status: docker-compose ps"
p "• Stop services: docker-compose down"
p "• Restart services: docker-compose restart"
p "• Stop wanaku server gracefully: stop-demo4-wanaku.sh"
p ""

p "🎉 Demo completed! Wanaku is ready to use."
