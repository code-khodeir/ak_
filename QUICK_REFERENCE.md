# Quick Reference Guide

## File Structure

```
ak_/
├── README.md                    # Main documentation
├── EXAMPLES.md                  # Usage examples
├── QUICK_REFERENCE.md          # This file
├── setup.sh                     # Setup script
├── validate.sh                  # Validation script
├── codex-mcp-config.json       # Codex MCP configuration
├── mcp-pool-config.json        # MCP pool configuration
├── investor-ops-stack.yaml     # Investor operations stack
├── .gitignore                   # Git ignore rules
└── maverick-mcp/               # MCP servers (excluded from git)
    └── src/
        ├── git/                 # Git MCP server
        ├── fetch/               # Fetch MCP server
        └── time/                # Time MCP server
```

## Quick Commands

### Setup

```bash
# Run complete setup
./setup.sh

# Validate configuration
./validate.sh
```

### Install Individual MCP Servers

```bash
# Git MCP Server
cd maverick-mcp/src/git && uv sync

# Fetch MCP Server (uses uvx - installed on demand)
# Time MCP Server (uses uvx - installed on demand)
```

### Run MCP Servers

```bash
# Git server
maverick-mcp/src/git/.venv/bin/python -m mcp_server_git

# Git server with repository
maverick-mcp/src/git/.venv/bin/python -m mcp_server_git --repository /path/to/repo

# Fetch server (via uvx)
uvx mcp-server-fetch

# Time server (via uvx)
uvx mcp-server-time
```

## Configuration Files

### codex-mcp-config.json

Defines MCP servers for Codex integration.

**Key sections:**
- `mcpServers`: Server definitions
  - `type`: Connection type (stdio/http)
  - `command`: Server executable
  - `args`: Command arguments
  - `env`: Environment variables

### mcp-pool-config.json

Connection pool and load balancing configuration.

**Key sections:**
- `pools`: Environment-specific pools (development/production)
  - `servers`: Server configurations with priorities
  - `connectionPool`: Connection limits
  - `idleTimeout`: Connection timeout
- `loadBalancing`: Load balancing strategy
- `monitoring`: Monitoring settings

### investor-ops-stack.yaml

Complete investor operations workflow.

**Key sections:**
- `components`: Stack components
  - `mcp_servers`: MCP server instances
  - `investor_services`: Business services
- `workflows`: Automated workflows
  - `daily_operations`: Daily tasks
  - `quarterly_operations`: Quarterly tasks
- `integrations`: External integrations
- `security`: Security policies
- `observability`: Logging and metrics

## Common Use Cases

### Use Case 1: Development Environment

```bash
# 1. Setup
./setup.sh

# 2. Use development pool
# Reference: mcp-pool-config.json -> pools.development

# 3. Lower resource limits
# Edit investor-ops-stack.yaml -> resource_limits
```

### Use Case 2: Production Deployment

```bash
# 1. Validate configuration
./validate.sh

# 2. Use production pool
# Reference: mcp-pool-config.json -> pools.production

# 3. Enable monitoring
# Check investor-ops-stack.yaml -> observability
```

### Use Case 3: Custom MCP Server

```bash
# 1. Add to codex-mcp-config.json
{
  "mcpServers": {
    "custom": {
      "type": "stdio",
      "command": "/path/to/server"
    }
  }
}

# 2. Add to mcp-pool-config.json
{
  "pools": {
    "development": {
      "servers": [
        {
          "name": "custom",
          "enabled": true
        }
      ]
    }
  }
}
```

## Environment Variables

### Required

- `CODEX_API_KEY`: Codex authentication (if using Codex)

### Optional

- `LOG_LEVEL`: Logging level (info/debug/error)
- `ENABLE_METRICS`: Enable metrics collection (true/false)
- `METRICS_PORT`: Metrics endpoint port (default: 9090)

## Troubleshooting

### Problem: "uv not found"

```bash
# Solution
pip install uv
```

### Problem: "Python module not found"

```bash
# Solution
cd maverick-mcp/src/git
uv sync
```

### Problem: "Invalid JSON/YAML"

```bash
# Solution
./validate.sh
```

### Problem: "Connection timeout"

```bash
# Solution: Increase timeout in mcp-pool-config.json
# Change timeout from 30000 to 60000 (or higher)
```

## Testing

### Test Git MCP Server

```bash
cd maverick-mcp/src/git
.venv/bin/python -m mcp_server_git --help
```

### Test Configuration Validity

```bash
# JSON validation
jq empty codex-mcp-config.json
jq empty mcp-pool-config.json

# YAML validation
python3 -c "import yaml; yaml.safe_load(open('investor-ops-stack.yaml'))"
```

### Test Complete Setup

```bash
./validate.sh
```

## Monitoring & Observability

### Metrics Endpoint

Default: `http://localhost:9090/metrics`

### Log Locations

- stdout (JSON format)
- Configurable in `investor-ops-stack.yaml`

### Health Checks

Configured in `mcp-pool-config.json`:
- Interval: 30 seconds
- Timeout: 5 seconds

## Security

### Network Policies

Defined in `investor-ops-stack.yaml`:
- Outbound: Allowed
- Inbound: Blocked (by default)
- Allowed ports: 443, 80

### Secrets Management

- Use environment variables
- Kubernetes secrets (for production)
- Never commit secrets to git

## Performance Tuning

### Connection Pool Sizing

Development:
- Min: 1, Max: 10

Production:
- Min: 2, Max: 20

### Resource Limits

Default (per stack):
- CPU: 2 cores
- Memory: 2Gi
- Storage: 10Gi

## Support

For issues with:
- **MCP servers**: See [Maverick-MCP Issues](https://github.com/modelcontextprotocol/servers/issues)
- **Configuration**: Check this repository's documentation
- **uv package manager**: See [uv documentation](https://github.com/astral-sh/uv)
