# ak_

## Maverick-MCP Integration

This repository contains the configuration for integrating Maverick-MCP (Model Context Protocol) servers with Codex and an investor-ops stack.

### Overview

- **maverick-mcp**: Cloned MCP servers repository (reference implementations)
- **codex-mcp-config.json**: Codex MCP server configuration
- **mcp-pool-config.json**: Reusable MCP pool configuration for load balancing and connection management
- **investor-ops-stack.yaml**: Complete investor operations stack with MCP integration

### Setup

#### Prerequisites

- Python 3.10+
- uv package manager
- Git

#### Installation

1. Clone the maverick-mcp repository (if not already present):
```bash
git clone https://github.com/modelcontextprotocol/servers.git maverick-mcp
```

2. Install uv package manager:
```bash
pip install uv
```

3. Install the MCP server runtimes:
```bash
# Install Git MCP Server
cd maverick-mcp/src/git
uv sync
cd ../../..

# Install Fetch MCP Server (uses uvx)
# Install Time MCP Server (uses uvx)
```

### Configuration Files

#### codex-mcp-config.json

Configures the MCP servers for Codex integration:
- **git**: Repository management and operations
- **fetch**: Web content fetching and conversion
- **time**: Time and timezone capabilities

#### mcp-pool-config.json

Provides reusable connection pool management with:
- Development and production pool configurations
- Connection pooling with configurable limits
- Load balancing with round-robin strategy
- Health checks and monitoring

#### investor-ops-stack.yaml

Complete investor operations stack featuring:
- MCP server components (git, fetch, time)
- Investor-specific services (portfolio analyzer, market data collector, reporting)
- Automated workflows (daily and quarterly operations)
- Security and observability configuration
- Resource management

### Usage

The configurations can be used to:
1. Connect MCP servers to Codex AI systems
2. Manage connection pools for multiple MCP servers
3. Deploy a complete investor operations workflow

### MCP Servers

This integration uses the following MCP reference servers:

- **Git Server**: Provides tools to read, search, and manipulate Git repositories
- **Fetch Server**: Web content fetching and conversion for efficient LLM usage
- **Time Server**: Time and timezone conversion capabilities

### Contributing

This is a configuration repository. For contributing to the MCP servers themselves, visit the [Maverick-MCP repository](https://github.com/modelcontextprotocol/servers).

### License

See LICENSE file for details.