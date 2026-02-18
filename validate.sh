#!/bin/bash
# Validation script for MCP configuration

set -e

echo "=== MCP Configuration Validation ==="
echo

# Check if configuration files exist
echo "Checking configuration files..."
CONFIG_FILES=(
    "codex-mcp-config.json"
    "mcp-pool-config.json"
    "investor-ops-stack.yaml"
)

for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
        
        # Validate JSON files
        if [[ "$file" == *.json ]]; then
            if command -v jq &> /dev/null; then
                if jq empty "$file" 2>/dev/null; then
                    echo "  ✓ Valid JSON"
                else
                    echo "  ✗ Invalid JSON"
                    exit 1
                fi
            else
                echo "  ⚠ jq not installed, skipping JSON validation"
            fi
        fi
        
        # Validate YAML files
        if [[ "$file" == *.yaml ]] || [[ "$file" == *.yml ]]; then
            if command -v python3 &> /dev/null; then
                if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                    echo "  ✓ Valid YAML"
                else
                    echo "  ✗ Invalid YAML"
                    exit 1
                fi
            else
                echo "  ⚠ python3 not installed, skipping YAML validation"
            fi
        fi
    else
        echo "✗ $file not found"
        exit 1
    fi
done

echo
echo "Checking maverick-mcp installation..."
if [ -d "maverick-mcp" ]; then
    echo "✓ maverick-mcp directory exists"
    
    # Check Git MCP Server
    if [ -d "maverick-mcp/src/git/.venv" ]; then
        echo "✓ Git MCP Server runtime installed"
        
        # Test if Git MCP server can run
        if maverick-mcp/src/git/.venv/bin/python -m mcp_server_git --help &> /dev/null; then
            echo "✓ Git MCP Server is executable"
        else
            echo "✗ Git MCP Server execution failed"
        fi
    else
        echo "✗ Git MCP Server runtime not installed"
        echo "  Run: cd maverick-mcp/src/git && uv sync"
    fi
else
    echo "✗ maverick-mcp directory not found"
    echo "  Run: git clone https://github.com/modelcontextprotocol/servers.git maverick-mcp"
fi

echo
echo "Checking uv installation..."
if command -v uv &> /dev/null; then
    echo "✓ uv is installed ($(uv --version))"
else
    # Check if uv is in ~/.local/bin
    if [ -x ~/.local/bin/uv ]; then
        echo "✓ uv is installed at ~/.local/bin/uv"
    else
        echo "✗ uv not found"
        echo "  Install with: pip install uv"
    fi
fi

echo
echo "=== Validation Complete ==="
echo
echo "Summary:"
echo "  Configuration files: OK"
echo "  MCP servers: $([ -d "maverick-mcp" ] && echo "OK" || echo "MISSING")"
echo "  Runtime setup: $([ -d "maverick-mcp/src/git/.venv" ] && echo "OK" || echo "INCOMPLETE")"
echo
