#!/bin/bash

# Demo 4 - Simple OpenAPI Server Setup with demo-magic
# This script demonstrates setting up a simple HTTP server with OpenAPI documentation

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
p "🚀 Demo 4: Simple OpenAPI Server Setup"
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

# Step 2: Check if Python 3 is available
p "📋 Step 2: Checking Python 3 availability..."
if ! command -v python3 &> /dev/null; then
    p "❌ Python 3 is not installed or not in PATH"
    exit 1
fi
pe "python3 --version"
p "✅ Python 3 is available!"
p ""

# Step 3: Check if virtual environment exists
p "📋 Step 3: Setting up Python virtual environment..."
if [ ! -d ".venv" ]; then
    p "📦 Creating virtual environment..."
    pe "python3 -m venv .venv"
    p "✅ Virtual environment created!"
else
    p "✅ Virtual environment already exists!"
fi
p ""

# Step 4: Activate virtual environment
p "📋 Step 4: Activating virtual environment..."
pe "source .venv/bin/activate"
p "✅ Virtual environment activated!"
p ""

# Step 5: Using existing environment
p "📋 Step 5: Using your existing Python environment..."
p "✅ No installation needed - using your configured environment!"
p ""

# Step 6: Check if port 8000 is available
p "📋 Step 6: Checking port 8000 availability..."
PORT_8000_PID=$(lsof -ti:8000 2>/dev/null)
if [ -n "$PORT_8000_PID" ]; then
    p "⚠️  Found process using port 8000 (PID: $PORT_8000_PID)"
    p "🛑 Stopping process on port 8000..."
    pe "kill -9 $PORT_8000_PID"
    p "✅ Port 8000 freed!"
else
    p "✅ Port 8000 is available!"
fi
p ""

# Step 7: Start the simple server
p "📋 Step 7: Starting Market Data API Server..."
p "🔍 This server provides:"
p "   • Real-time market data (stock quotes, symbols)"
p "   • RESTful API endpoints for financial data"
p "   • Automatic OpenAPI specification generation"
p "   • Interactive documentation with Swagger UI"
p ""
p "🔍 Server will be available at:"
p "   • API Root: http://localhost:8000/"
p "   • Swagger UI: http://localhost:8000/swagger"
p "   • OpenAPI JSON: http://localhost:8000/openapi.json"
p ""
p "🚀 Starting server in background..."
pe "nohup python3 yfinServer.py > server.log 2>&1 &"
p "✅ Server started!"
p ""

# Step 8: Wait a moment for server to start
p "📋 Step 8: Waiting for server to initialize..."
pe "sleep 5"
p "🔍 Verifying server is running..."
SERVER_PID=$(pgrep -f "yfinServer.py" 2>/dev/null)
if [ -n "$SERVER_PID" ]; then
    p "✅ Server is running (PID: $SERVER_PID)!"
else
    p "❌ Server failed to start!"
    p "🔍 Checking server logs..."
    pe "cat server.log"
    exit 1
fi
p ""

# Step 9: Generate Wanaku tools from OpenAPI
p "📋 Step 9: Generating Wanaku tools from OpenAPI..."
p "🔍 Executing Wanaku tools generation..."
p "🔧 Generating tools and capturing output..."
pe "wanaku tools generate http://localhost:8000/openapi.json > generated_tools.json"
p "✅ Wanaku tools generated and saved to generated_tools.json!"
p "🔧 Post-processing generated tools to replace localhost with host.docker.internal..."
pe "sed -i '' 's|http://localhost:8000|http://host.docker.internal:8000|g' generated_tools.json"
p "✅ Tools post-processed for container access!"
p "🔍 Importing corrected tools..."
pe "wanaku tools import generated_tools.json"
p "✅ Tools imported successfully!"
p "🔍 Verifying imported tools..."
pe "wanaku tools list"
p "✅ Tools verification completed!"
p ""

# Step 10: Start Claude Desktop
p "📋 Step 10: Starting Claude Desktop..."
pe "/Applications/Claude.app/Contents/MacOS/Claude &"
p "✅ Claude Desktop started!"
p ""

# Step 11: Show next steps
p "📋 Next steps:"
p "• Open http://localhost:8000/swagger in your browser to see the interactive API documentation"
p "• Open http://localhost:8000/openapi.json for OpenAPI specification"
p "• The server provides sample market data with automatic OpenAPI generation"
p ""

# Step 12: Show useful commands
p "📋 Useful commands:"
p "• Use prompt: what is the latest AAPL market quote ? "
p "• Check Wanaku server log : podman logs wanaku-router"
p "• Stop server: pkill -f yfinServer.py"
p "• Wanaku tools: wanaku capabilities list"
p ""

p "🎉 Demo 4 completed! Simple OpenAPI server is running on port 8000 with Wanaku integration."
