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

# Step 3: Copy file to accessible location and expose the resource
p "Step 3: Copy file to accessible location and expose the resource"
pe "cd ../../wanaku && docker-compose exec wanaku-provider-file sh -c \"cp /home/default/.wanaku/sample-text.txt /tmp/sample-text.txt && chown 185:185 /tmp/sample-text.txt\""
pe "wanaku resources expose --location=/tmp/sample-text.txt --mimeType=text/plain --description=\"Sample text for AI summarization demo\" --name=\"myText\" --type=file"
p ""

# Step 4: Check that resources have been exposed
p "Step 4: List resources"
pe "wanaku resources list"
p ""

p "✅ Step 1 completed!"
p ""
p "Use this prompt to summarize the exposed text:"
p "You are an expert content summarizer. You take content in and output a Markdown formatted summary using the format below."
p ""
p "# OUTPUT SECTIONS"
p "- Combine all of your understanding of the content into a single, 20-word sentence in a section called ONE SENTENCE SUMMARY:."
p "- Output the 10 most important points of the content as a list with no more than 15 words per point into a section called MAIN POINTS:"
p "- Output a list of the 5 best takeaways from the content in a section called TAKEAWAYS:."
p ""
p "# OUTPUT INSTRUCTIONS"
p "- Create the output using the formatting above."
p "- You only output human readable Markdown."
p "- Output numbered lists, not bullets."
p "- Do not output warnings or notes—just the requested sections."
p "- Do not repeat items in the output sections."
p "- Do not start items with the same opening words."
