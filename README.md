# myserv CLI

Command line for [MyServ Apps](https://myserv.ge): deploy services, read logs, manage variables and open a shell in a container.

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
```

`<service>` is a service name, or `project/service` when the name is used in more than one project. Every command takes `--json`.

### GitHub Actions

```yaml
- run: curl -fsSL https://raw.githubusercontent.com/MyServ-ge/myserv-cli/main/install.sh | sh
- run: myserv deploy api --wait
  env:
    MYSERV_TOKEN: ${{ secrets.MYSERV_TOKEN }}
```
