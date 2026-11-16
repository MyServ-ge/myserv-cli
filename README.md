# myserv CLI

Command line for [MyServ Apps](https://myserv.ge): deploy services, read logs, manage variables and open a shell in a container. It also lets AI assistants (Claude Code, Cursor, VS Code) do the same for you.

This repository holds release builds only.

## Install

macOS and Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/MyServ-ge/myserv-cli/main/install.sh | sh
```

Windows: download `myserv_<version>_windows_amd64.zip` from [Releases](https://github.com/MyServ-ge/myserv-cli/releases) and put `myserv.exe` on your `PATH`.

Every release has a `checksums.txt` (SHA-256); the install script checks it.

## Log in

Create an API key in the portal (MyServ Apps → API keys), then:

```sh
myserv login
```

In CI (for example GitHub Actions) set `MYSERV_TOKEN` to the key instead.

## Commands

```
myserv whoami
myserv services
myserv status <service>
myserv deploy <service> [--wait]
myserv logs <service> [-f] [--lines N]
myserv env list <service>
myserv env set NAME=VALUE [--secret] <service>
myserv env unset NAME <service>
myserv shell <service>
myserv mcp
```

`<service>` is a service name, or `project/service` when the name is used in more than one project. Every command takes `--json`.

## AI assistants (MCP)

`myserv mcp` serves the commands above as tools over the [Model Context Protocol](https://modelcontextprotocol.io), so an AI assistant can check your services, read logs and build logs, deploy and manage variables. It uses the key from `myserv login` (or `MYSERV_TOKEN`). Needs v0.2.0 or newer.

Claude Code:

```sh
claude mcp add myserv -- myserv mcp
```

Cursor, VS Code and other MCP clients: add a server with the command `myserv` and the argument `mcp`, for example in `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "myserv": { "command": "myserv", "args": ["mcp"] }
  }
}
```

Then ask, for example: "Why did the last deploy of api fail?" or "Show the errors in the web logs from the last hour."

| Tool | What it does |
|---|---|
| `whoami` | the team, plan and status |
| `list_services` | every service with its status and latest deployment |
| `service_status` | one service and its latest deployment |
| `list_deployments` | a service's deployments, newest first |
| `deployment_build_logs` | the build and release logs of a deployment |
| `service_logs` | recent logs of a running service |
| `deploy` | deploy the branch head; can wait for the result |
| `list_env` | a service's variables (secret values are not shown) |
| `set_env`, `unset_env` | change variables; they apply on the next deploy |

Your assistant asks before it runs a tool that changes something, unless you allow it.

### GitHub Actions

```yaml
- run: curl -fsSL https://raw.githubusercontent.com/MyServ-ge/myserv-cli/main/install.sh | sh
- run: myserv deploy api --wait
  env:
    MYSERV_TOKEN: ${{ secrets.MYSERV_TOKEN }}
```
