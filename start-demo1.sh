#!/bin/bash

# Demo 1 - PostgreSQL MCP Server Setup with demo-magic
# This script demonstrates setting up the PostgreSQL MCP server for Claude Desktop

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
p "🐘 Demo 1: PostgreSQL MCP Server Setup"
p "====================================="
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

# Step 2: Start PostgreSQL database
p "📋 Step 2: Starting PostgreSQL database with Netflix data..."
p "🛑 Cleaning up any existing PostgreSQL containers..."
pe "podman stop $(podman ps -q --filter ancestor=docker.io/library/postgres:latest) 2>/dev/null || true"
pe "podman rm $(podman ps -aq --filter ancestor=docker.io/library/postgres:latest) 2>/dev/null || true"
pe "podman stop my-postgres-db 2>/dev/null || true"
pe "podman rm my-postgres-db 2>/dev/null || true"
p "🚀 Starting PostgreSQL container with Netflix database..."
pe "podman run --name my-postgres-db -d -e POSTGRES_PASSWORD=your_secret_password -e POSTGRES_USER=myuser -e POSTGRES_DB=mydatabase -v $(pwd)/demos/demo-1-postgresql/init-db:/docker-entrypoint-initdb.d:Z -v postgres_data:/var/lib/postgresql/data:Z -p 5432:5432 docker.io/library/postgres:latest"
p "⏳ Waiting for PostgreSQL to initialize and load Netflix data..."
pe "sleep 15"
p "🔍 Verifying PostgreSQL container is running..."
pe "podman ps --filter name=my-postgres-db"
p "✅ PostgreSQL database is ready!"
p ""

# Step 3: Check if the source config file exists
p "📋 Step 3: Checking source configuration file..."
SOURCE_CONFIG="$(dirname "$0")/demos/demo-1-postgresql/claude_desktop_config.json"
if [ -f "$SOURCE_CONFIG" ]; then
    p "✅ Source config file found: $SOURCE_CONFIG"
    pe "cat '$SOURCE_CONFIG'"
else
    p "❌ Source config file not found: $SOURCE_CONFIG"
    p "Exiting..."
    exit 1
fi
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

# Step 6: Copy the PostgreSQL MCP configuration
p "📋 Step 6: Installing PostgreSQL MCP server configuration..."
pe "cp '$SOURCE_CONFIG' '$TARGET_CONFIG'"
p "✅ Configuration copied successfully!"
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

# Step 9: Show next steps
p "📋 Next steps:"
p "• Claude Desktop should now have access to the PostgreSQL MCP server"
p "• You can test the connection by asking Claude to query your database"
p "• The MCP server will connect to: postgresql://myuser:your_secret_password@localhost:5432/mydatabase"
p ""

p "🎉 Demo 1 setup completed! PostgreSQL MCP server is now configured in Claude Desktop."
