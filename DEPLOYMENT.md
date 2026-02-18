# Deployment Guide

## Overview

This guide walks through deploying the Maverick-MCP integration with Codex and the investor-ops stack.

## Prerequisites

- Linux/macOS environment
- Python 3.10 or higher
- Git
- Internet connectivity for initial setup

## Quick Start

### 1. Clone and Setup

```bash
# Clone this repository (if you haven't already)
git clone https://github.com/code-khodeir/ak_.git
cd ak_

# Run the setup script
./setup.sh
```

This will:
- Clone the maverick-mcp repository
- Install the uv package manager
- Set up the Git MCP server runtime

### 2. Validate Configuration

```bash
./validate.sh
```

This validates:
- All configuration files (JSON and YAML syntax)
- MCP server installations
- Runtime environment

### 3. Test Individual Components

#### Test Git MCP Server

```bash
maverick-mcp/src/git/.venv/bin/python -m mcp_server_git --help
```

Expected output:
```
Usage: python -m mcp_server_git [OPTIONS]
  MCP Git Server - Git functionality for MCP
Options:
  -r, --repository PATH  Git repository path
  -v, --verbose
  --help                 Show this message and exit.
```

## Configuration Files

### codex-mcp-config.json

Location: `/home/runner/work/ak_/ak_/codex-mcp-config.json`

**Purpose**: Defines MCP servers for Codex integration

**Servers Configured**:
1. Git MCP Server - Repository operations
2. Fetch MCP Server - Web content retrieval
3. Time MCP Server - Timezone operations

**Customization**:
```json
{
  "mcpServers": {
    "custom-server": {
      "type": "stdio",
      "command": "/path/to/your/server",
      "args": ["--config", "config.json"],
      "description": "Your custom MCP server",
      "env": {
        "ENV_VAR": "value"
      }
    }
  }
}
```

### mcp-pool-config.json

Location: `/home/runner/work/ak_/ak_/mcp-pool-config.json`

**Purpose**: Connection pooling and load balancing for MCP servers

**Pools Available**:
- `development`: Lower resource limits, suitable for testing
- `production`: Higher resource limits and retry counts

**Key Settings**:
- Connection pool sizes (min/max)
- Timeout values per server
- Retry strategies
- Health check intervals

**Switching Pools**:
```bash
# Development
export MCP_POOL=development

# Production
export MCP_POOL=production
```

### investor-ops-stack.yaml

Location: `/home/runner/work/ak_/ak_/investor-ops-stack.yaml`

**Purpose**: Complete investor operations workflow orchestration

**Components**:
1. **MCP Servers**: git-server, fetch-server, time-server
2. **Investor Services**:
   - portfolio-analyzer
   - market-data-collector
   - investor-reporting

**Workflows**:
- Daily operations (weekdays at 9 AM, 10 AM, 5 PM)
- Quarterly operations (first day of quarter)

## Deployment Scenarios

### Scenario 1: Local Development

```bash
# 1. Setup
./setup.sh

# 2. Validate
./validate.sh

# 3. Run with development pool
export MCP_POOL=development
export LOG_LEVEL=debug

# 4. Test individual servers
maverick-mcp/src/git/.venv/bin/python -m mcp_server_git --repository .
```

### Scenario 2: Production Deployment

```bash
# 1. Setup and validate
./setup.sh
./validate.sh

# 2. Configure environment
export MCP_POOL=production
export LOG_LEVEL=info
export ENABLE_METRICS=true
export METRICS_PORT=9090
export CODEX_API_KEY="your-api-key"

# 3. Deploy with orchestration tool (e.g., Docker, K8s)
# See docker-compose example below
```

### Scenario 3: Docker Deployment

Create a `docker-compose.yml`:

```yaml
version: '3.8'

services:
  git-mcp-server:
    image: python:3.10-slim
    working_dir: /app
    volumes:
      - ./maverick-mcp/src/git:/app
      - ./codex-mcp-config.json:/config/codex-mcp-config.json
    command: [".venv/bin/python", "-m", "mcp_server_git"]
    environment:
      - LOG_LEVEL=info
    ports:
      - "8080:8080"
    restart: unless-stopped

  # Add other services as needed
```

### Scenario 4: Kubernetes Deployment

Use the `investor-ops-stack.yaml` as a reference for Kubernetes configurations:

```bash
# Create ConfigMaps
kubectl create configmap codex-mcp-config --from-file=codex-mcp-config.json
kubectl create configmap mcp-pool-config --from-file=mcp-pool-config.json

# Create Secrets
kubectl create secret generic api-credentials \
  --from-literal=CODEX_API_KEY=your-api-key

# Apply the stack configuration (after converting to K8s format)
kubectl apply -f investor-ops-stack-k8s.yaml
```

## Monitoring and Observability

### Metrics

Access metrics at: `http://localhost:9090/metrics`

**Key Metrics**:
- Server response times
- Connection pool utilization
- Error rates
- Request throughput

### Logs

**Default Location**: stdout (JSON format)

**Log Levels**:
- `debug`: Verbose debugging information
- `info`: General operational information (default)
- `warning`: Warning messages
- `error`: Error messages

**Example Log Entry**:
```json
{
  "timestamp": "2024-02-18T23:00:00Z",
  "level": "info",
  "service": "git-server",
  "message": "Server started successfully",
  "metadata": {
    "version": "0.6.2",
    "pool": "production"
  }
}
```

### Health Checks

**Endpoint**: `/health`

**Checks**:
- Server availability
- Connection pool status
- Dependent service status

**Intervals**:
- Check interval: 30 seconds
- Timeout: 5 seconds

## Security Considerations

### Network Security

1. **Inbound Traffic**: Blocked by default
2. **Outbound Traffic**: Allowed to ports 80, 443
3. **Service Communication**: Internal only

### Secrets Management

**DO NOT** commit secrets to git. Use:

1. Environment variables
2. Secret management services (AWS Secrets Manager, HashiCorp Vault)
3. Kubernetes secrets (for K8s deployments)

**Example**:
```bash
# Set environment variables
export CODEX_API_KEY=$(cat /path/to/secret)

# Or use a .env file (gitignored)
echo "CODEX_API_KEY=your-key" > .env
source .env
```

### Best Practices

1. Use least privilege principle for service accounts
2. Enable TLS/SSL for external communications
3. Rotate credentials regularly
4. Monitor for suspicious activity
5. Keep dependencies updated

## Troubleshooting

### Issue: Setup Script Fails

**Symptoms**: Error during `./setup.sh`

**Solutions**:
```bash
# Check Python version
python3 --version  # Should be 3.10+

# Check git
git --version

# Check network connectivity
ping github.com

# Manual setup
pip install uv
cd maverick-mcp/src/git
uv sync
```

### Issue: Validation Errors

**Symptoms**: `./validate.sh` reports errors

**Solutions**:
```bash
# Check JSON syntax
jq empty codex-mcp-config.json

# Check YAML syntax
python3 -c "import yaml; yaml.safe_load(open('investor-ops-stack.yaml'))"

# Re-run setup
./setup.sh
```

### Issue: Server Not Starting

**Symptoms**: MCP server fails to start

**Solutions**:
```bash
# Check logs
maverick-mcp/src/git/.venv/bin/python -m mcp_server_git -v

# Check dependencies
cd maverick-mcp/src/git
uv sync

# Check permissions
chmod +x maverick-mcp/src/git/.venv/bin/python
```

### Issue: Connection Timeouts

**Symptoms**: Requests timing out

**Solutions**:
```json
// Increase timeouts in mcp-pool-config.json
{
  "servers": [{
    "timeout": 120000  // Increase from 60000
  }]
}
```

## Performance Tuning

### Connection Pool Sizing

**Guidelines**:
- Start conservative (min: 1-2, max: 10-20)
- Monitor utilization
- Increase if connections are frequently maxed out
- Decrease if idle connections are high

### Resource Allocation

**Per Server**:
- Git: 512Mi memory, 0.5 CPU
- Fetch: 256Mi memory, 0.25 CPU
- Time: 128Mi memory, 0.1 CPU

**Adjust based on**:
- Request volume
- Response time requirements
- Available infrastructure

### Caching Strategies

Consider implementing:
1. Response caching for frequent queries
2. Connection pooling
3. Keep-alive connections

## Maintenance

### Updates

```bash
# Update maverick-mcp
cd maverick-mcp
git pull origin main

# Update dependencies
cd src/git
uv sync

# Validate after updates
cd ../../..
./validate.sh
```

### Backup

**Configuration Files**:
```bash
# Backup configs
tar -czf config-backup-$(date +%Y%m%d).tar.gz \
  codex-mcp-config.json \
  mcp-pool-config.json \
  investor-ops-stack.yaml
```

### Monitoring

Regular checks:
- Server health: Daily
- Logs review: Daily
- Metrics analysis: Weekly
- Security updates: Monthly

## Support and Resources

- **MCP Documentation**: https://modelcontextprotocol.io/
- **Maverick-MCP**: https://github.com/modelcontextprotocol/servers
- **uv Package Manager**: https://github.com/astral-sh/uv
- **This Repository**: https://github.com/code-khodeir/ak_

## Appendix

### Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `CODEX_API_KEY` | No* | - | Codex authentication key |
| `LOG_LEVEL` | No | `info` | Logging level |
| `ENABLE_METRICS` | No | `true` | Enable metrics collection |
| `METRICS_PORT` | No | `9090` | Metrics endpoint port |
| `MCP_POOL` | No | `development` | MCP pool to use |

\* Required if using Codex integration

### File Locations

| File | Location | Purpose |
|------|----------|---------|
| `codex-mcp-config.json` | Root | Codex MCP configuration |
| `mcp-pool-config.json` | Root | Pool configuration |
| `investor-ops-stack.yaml` | Root | Stack configuration |
| `setup.sh` | Root | Setup script |
| `validate.sh` | Root | Validation script |
| `maverick-mcp/` | Root | MCP servers (excluded from git) |

### Command Reference

| Command | Purpose |
|---------|---------|
| `./setup.sh` | Initial setup |
| `./validate.sh` | Validate configuration |
| `maverick-mcp/src/git/.venv/bin/python -m mcp_server_git` | Run Git server |
| `uvx mcp-server-fetch` | Run Fetch server |
| `uvx mcp-server-time` | Run Time server |
