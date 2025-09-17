#!/bin/bash

# Script to kill processes using a specific port
# Usage: ./kill-port.sh <port_number>

# Check if port number is provided
if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide a port number"
    echo "Usage: $0 <port_number>"
    echo "Example: $0 8080"
    exit 1
fi

PORT=$1

# Check if port is a valid number
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: Port must be a number"
    exit 1
fi

echo "🔍 Checking for processes using port $PORT..."

# Find processes using the port
PIDS=$(lsof -ti:$PORT 2>/dev/null)

if [ -z "$PIDS" ]; then
    echo "✅ No processes found using port $PORT"
    exit 0
fi

echo "⚠️  Found processes using port $PORT:"
lsof -i:$PORT

echo ""
echo "🛑 Killing processes..."

# Kill each process
for PID in $PIDS; do
    echo "   Killing PID: $PID"
    kill -9 $PID 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "   ✅ Successfully killed PID: $PID"
    else
        echo "   ❌ Failed to kill PID: $PID"
    fi
done

# Wait a moment and check if processes are still running
sleep 1

# Check if any processes are still using the port
REMAINING_PIDS=$(lsof -ti:$PORT 2>/dev/null)

if [ -z "$REMAINING_PIDS" ]; then
    echo "✅ Port $PORT is now free"
else
    echo "⚠️  Some processes may still be using port $PORT:"
    lsof -i:$PORT
fi
