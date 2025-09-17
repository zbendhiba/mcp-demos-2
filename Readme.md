# Demo 1: Try an existing MCP server

In this demo we will try a simple MCP server in order to witness how easy is it to use an MCP server.

## Try an MCP tool

For this demo, we will launch a PostgreSQL MCP server an see how far we can play with it.

The MCP server used is the [Postgresql MCP server](https://github.com/modelcontextprotocol/servers-archived/tree/main/src/postgres).

# Start Wanaku server

## Requirements: 

1. Podman or Docker 
2. An LLM endpoint (can be locally hosted, like Ollama)

## Download Wanaku CLI (CLI) - Optional

The CLI can be used to manage the Wanaku router. You can download the CLI from the [releases page](https://github.com/wanaku-ai/wanaku/releases).

The CLI is distributed in two flavors: 

* Native binaries for Linux and macOS
* Java-based binaries for all operating systems

For instance, to get the Wanaku CLI for macOS:

```shell
wget https://github.com/wanaku-ai/wanaku/releases/download/v0.0.7/cli-0.0.7-osx-aarch_64.zip
unzip cli-0.0.7-osx-aarch_64.zip
install -m 750 cli-0.0.7-osx-aarch_64/bin/cli $HOME/bin/wanaku
rm -rf cli-0.0.7-osx-aarch_64 cli-0.0.7-osx-aarch_64.zip
```

> [!NOTE]
> Make sure to adjust this according to your OS. 

Check if it was installed successfully:

```shell
wanaku --version
```

Expected result:
```
Wanaku CLI version 0.0.7
Usage: wanaku [-hv] [COMMAND]
  -h, --help      Display the help and sub-commands
  -v, --version   Display the current version of Wanaku CLI
Commands:
  forwards      Manage forwards
  resources     Manage resources
  start         Start Wanaku
  capabilities  Manage capabilities
  targets       Manage targets
  tools         Manage tools
  toolset       Manage toolsets
  namespaces    Manage namespaces

```

## Checking the Environment

Check if podman is available (adjust the command if you use docker).

```shell
podman ps
```

## Lanche the containers

I'm using demo magic in order to start my server dynamically while I'm making my demos.

Feel free to use it, but please check the license here: https://github.com/paxtonhare/demo-magic

### Requirements

Check that the scripts are executable `start-wanaku.sh`, `.bin/demo-magic.sh` and `wanaku/stop-and-cleanup.sh`
If needed, execute this 

```shell
chmod +x start-wanaku.sh
chmod +x .bin/demo-magic.sh
chmod +x wanaku/stop-and-cleanup.sh
```

### Launch Wanaku with one script

```shell
./start-wanaku.sh
```


# Stop Wanaku Server

### Requirements

Make sure the `stop-wanaku.sh` file is executable. If needed:
```shell
chmod +x stop-wanaku.sh
```

Stop and remove the containers.

```shell
cd wanaku
./stop-wanaku.sh
```
