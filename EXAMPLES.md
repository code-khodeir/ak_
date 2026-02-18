# MCP Integration Examples

This document provides examples of how to use the MCP configurations in this repository.

## Prerequisites

Run the setup script first:
```bash
./setup.sh
```

## Example 1: Using Git MCP Server

The Git MCP Server provides tools to interact with Git repositories.

### Starting the Git MCP Server

```bash
# Start the Git MCP server with a specific repository
maverick-mcp/src/git/.venv/bin/python -m mcp_server_git --repository /path/to/repo
```

### Configuration in codex-mcp-config.json

```json
{
  "mcpServers": {
    "git": {
      "type": "stdio",
      "command": "/home/runner/work/ak_/ak_/maverick-mcp/src/git/.venv/bin/python",
      "args": ["-m", "mcp_server_git"],
      "description": "Git repository management and operations"
    }
  }
}
```

## Example 2: Using MCP Pool Configuration

The pool configuration provides load balancing and connection management.

### Development Pool

For development environments with lower resource requirements:

```json
{
  "pools": {
    "development": {
      "connectionPool": {
        "minConnections": 1,
        "maxConnections": 10,
        "idleTimeout": 60000
      }
    }
  }
}
```

### Production Pool

For production environments with higher reliability:

```json
{
  "pools": {
    "production": {
      "connectionPool": {
        "minConnections": 2,
        "maxConnections": 20,
        "idleTimeout": 120000
      }
    }
  }
}
```

## Example 3: Investor Operations Stack

The investor-ops stack demonstrates a complete workflow configuration.

### Daily Operations Workflow

Automatically runs on weekdays:
- 9 AM: Collect market data
- 10 AM: Analyze portfolio
- 5 PM: Generate reports

### Quarterly Operations Workflow

Runs on the first day of each quarter:
- 9 AM: Comprehensive analysis
- 12 PM: Regulatory reporting

### Using the Stack

```yaml
workflows:
  daily_operations:
    - step: collect_market_data
      service: market-data-collector
      schedule: "0 9 * * 1-5"
```

## Example 4: Integrating with Codex

To integrate these MCP servers with Codex AI:

1. Point Codex to the configuration file:
   ```bash
   export CODEX_MCP_CONFIG=/home/runner/work/ak_/ak_/codex-mcp-config.json
   ```

2. Ensure the MCP servers are accessible
3. Configure authentication if required

## Example 5: Testing Individual Servers

### Test Git Server

```bash
cd maverick-mcp/src/git
.venv/bin/python -m mcp_server_git --help
```

### Test with a Repository

```bash
cd maverick-mcp/src/git
.venv/bin/python -m mcp_server_git --repository /path/to/your/repo
```

## Example 6: Custom Configuration

You can extend the configurations for your specific needs:

### Adding a New MCP Server

Edit `codex-mcp-config.json`:

```json
{
  "mcpServers": {
    "your-server": {
      "type": "stdio",
      "command": "/path/to/your/server",
      "args": ["--config", "/path/to/config"],
      "description": "Your custom MCP server",
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

### Adding a New Pool

Edit `mcp-pool-config.json`:

```json
{
  "pools": {
    "staging": {
      "servers": [
        {
          "name": "your-server",
          "enabled": true,
          "priority": "high",
          "timeout": 30000,
          "retries": 3
        }
      ]
    }
  }
}
```

## Troubleshooting

### Issue: MCP Server Not Found

Solution: Ensure the runtime is installed:
```bash
cd maverick-mcp/src/git
uv sync
```

### Issue: Configuration Validation Errors

Solution: Run the validation script:
```bash
./validate.sh
```

### Issue: Connection Timeouts

Solution: Increase timeout values in `mcp-pool-config.json`:
```json
{
  "servers": [
    {
      "timeout": 60000  // Increase from 30000
    }
  ]
}
```

## Best Practices

1. **Use Environment Variables**: Store sensitive data in environment variables
2. **Monitor Resources**: Enable monitoring in `investor-ops-stack.yaml`
3. **Test Configurations**: Always validate configurations before deployment
4. **Scale Gradually**: Start with development pool, then move to production
5. **Keep Logs**: Enable logging for debugging and auditing

## Additional Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Maverick-MCP Repository](https://github.com/modelcontextprotocol/servers)
- [uv Documentation](https://github.com/astral-sh/uv)
