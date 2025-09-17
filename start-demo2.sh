#!/bin/bash

# Demo 2 - Quarkus MCP Server Setup with demo-magic
# This script demonstrates setting up the Quarkus MCP server for Claude Desktop

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
p "☕ Demo 2: Quarkus MCP Server Setup"
p "=================================="
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

# Step 2: Check if the Quarkus MCP server binary exists
p "📋 Step 2: Checking Quarkus MCP server binary..."
MCP_SERVER_BINARY="$(dirname "$0")/demos/demo2-mcp-server-stdio/image/demo2-mcp-server-stdio-1.0.0-SNAPSHOT-runner"
if [ -f "$MCP_SERVER_BINARY" ]; then
    p "✅ MCP server binary found: $MCP_SERVER_BINARY"
    pe "ls -la '$MCP_SERVER_BINARY'"
else
    p "❌ MCP server binary not found: $MCP_SERVER_BINARY"
    p "Please build the Quarkus application first with: ./mvnw package -Dnative"
    p "Exiting..."
    exit 1
fi
p ""

# Step 3: Configuration will be generated dynamically
p "📋 Step 3: Configuration will be generated dynamically..."
p "✅ No source config file needed - will generate at runtime"
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

# Step 6: Generate and copy the Quarkus MCP configuration
p "📋 Step 6: Installing Quarkus MCP server configuration..."
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_SERVER_PATH="$PROJECT_DIR/demos/demo2-mcp-server-stdio/image/demo2-mcp-server-stdio-1.0.0-SNAPSHOT-runner"
p "🔍 MCP Server Path: $MCP_SERVER_PATH"
p "📝 Generating configuration file..."
echo "{
    \"mcpServers\": {
      \"time-mcp-server\": {
        \"command\" : \"$MCP_SERVER_PATH\"
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
p "🔍 Launching MCP Inspector with Quarkus MCP server in a new terminal window..."
pe "osascript -e 'tell application \"Terminal\" to do script \"cd $(pwd) && npx @modelcontextprotocol/inspector $(pwd)/demos/demo2-mcp-server-stdio/image/demo2-mcp-server-stdio-1.0.0-SNAPSHOT-runner\"'"
p "✅ MCP Inspector started!"
p ""

# Step 10: Show next steps
p "📋 Next steps:"
p "• Claude Desktop should now have access to the Quarkus MCP server"
p "• You can test the connection by asking Claude about time-related queries"
p "• The MCP server provides time and clock functionality"
p ""

p "🎉 Demo 2 setup completed! Quarkus MCP server is now configured in Claude Desktop."
p ""

p " Use the following prompt in Claude Desktop: What is the current time?"

p "Check the MCP Inspector to see the capabilities of the Quarkus MCP server, open : http://localhost:6274/"
p "Put the command line \"$(pwd)/demos/demo2-mcp-server-stdio/image/demo2-mcp-server-stdio-1.0.0-SNAPSHOT-runner\""

