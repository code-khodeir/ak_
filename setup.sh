#!/bin/bash
# Setup script for Maverick-MCP integration

set -e

echo "=== Maverick-MCP Setup Script ==="
echo

# Check if maverick-mcp exists
if [ ! -d "maverick-mcp" ]; then
    echo "Cloning maverick-mcp repository..."
    git clone https://github.com/modelcontextprotocol/servers.git maverick-mcp
    echo "✓ Cloned maverick-mcp"
else
    echo "✓ maverick-mcp directory already exists"
fi

# Check for uv
if ! command -v uv &> /dev/null; then
    echo "Installing uv package manager..."
    pip install uv
    echo "✓ Installed uv"
else
    echo "✓ uv is already installed"
fi

# Install Git MCP Server
echo
echo "Setting up Git MCP Server..."
cd maverick-mcp/src/git
if [ ! -d ".venv" ]; then
    uv sync
    echo "✓ Git MCP Server runtime installed"
else
    echo "✓ Git MCP Server runtime already installed"
fi
cd ../../..

# Install Fetch MCP Server (optional - uses uvx)
echo
echo "Note: Fetch and Time MCP servers use 'uvx' and will be installed on first use"

echo
echo "=== Setup Complete ==="
echo
echo "Configuration files created:"
echo "  - codex-mcp-config.json"
echo "  - mcp-pool-config.json"
echo "  - investor-ops-stack.yaml"
echo
echo "To test the Git MCP server, run:"
echo "  maverick-mcp/src/git/.venv/bin/python -m mcp_server_git"
echo
