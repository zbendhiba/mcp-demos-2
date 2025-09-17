#!/bin/bash

# Step 1 - Start Quarkus MCP Server with Wanaku
# This script adds the Quarkus MCP server to Wanaku forwards

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
p "🚀 Step 1: Start Quarkus MCP Server with Wanaku"
p "=============================================="
p ""

# Step 1: Add Quarkus MCP server to Wanaku forwards
p "Step 1: Add Quarkus MCP server"
pe "wanaku forwards add --service=\"http://host.docker.internal:8081/mcp/sse\" --name my-quarkus-mcp-server"
p ""

# Step 2: Verify the MCP server has been added
p "Step 2: Verify forwards"
pe "wanaku forwards list"
p ""

# Step 3: Add Telegram tool
p "Step 3: Add Telegram tool"
pe "wanaku tools add --name telegram --uri \"telegram://bots\" --description 'Sends telegram message to Zineb' --property 'message:string, the message to send to the customer' --required=message --type telegram://bots"
p ""

# Step 4: Check that tools have been added
p "Step 4: List tools"
pe "wanaku tools list"
p ""

p "✅ Step 1 completed!"

p "Use the prumpot: send the current time to Zineb via the telegram service"
