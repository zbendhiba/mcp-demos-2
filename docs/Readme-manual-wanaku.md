# Install Wanaku

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

## Launching Wanaku MCP Router from the Docker Compose file

Launch the containers.

```shell
cd wanaku
docker-compose up -d
```

**NOTE**: Wanaku is composed of several different services that will automatically register themselves, expose configurations and perform other initializations tasks, therefore, it may take a couple of seconds for it to start.

Check if the containers have launched.

```
podman ps
```

Expected result: 

```shell
CONTAINER ID  IMAGE                                                       COMMAND     CREATED             STATUS                       PORTS                   NAMES
c7a8887dac81  quay.io/wanaku/wanaku-router:wanaku-0.0.7                               About a minute ago  Up About a minute (healthy)  0.0.0.0:8080->8080/tcp  wanaku-router
625d1b2eaea5  quay.io/wanaku/wanaku-tool-service-tavily:wanaku-0.0.7                  About a minute ago  Up About a minute            0.0.0.0:9006->9000/tcp  wanaku-tool-service-tavily
2effb786b243  quay.io/wanaku/wanaku-tool-service-yaml-route:wanaku-0.0.7              About a minute ago  Up About a minute            0.0.0.0:9001->9000/tcp  wanaku-tool-service-yaml-route
7179f3e678c0  quay.io/wanaku/wanaku-tool-service-http:wanaku-0.0.7                    About a minute ago  Up About a minute            0.0.0.0:9000->9000/tcp  wanaku-tool-service-http
4103e60fa55b  quay.io/wanaku/wanaku-provider-s3:wanaku-0.0.7                          About a minute ago  Up About a minute            0.0.0.0:9005->9000/tcp  wanaku-provider-s3
4121cc6be579  quay.io/wanaku/wanaku-provider-file:wanaku-0.0.7                        About a minute ago  Up About a minute            0.0.0.0:9002->9000/tcp  wanaku-provider-file
5dc89164801d  quay.io/wanaku/wanaku-provider-ftp:wanaku-0.0.7                         About a minute ago  Up About a minute            0.0.0.0:9004->9000/tcp  wanaku-provider-ftp
ce22f4bb58d2  quay.io/wanaku/wanaku-tool-service-kafka:wanaku-0.0.7                   About a minute ago  Up About a minute            0.0.0.0:9003->9000/tcp  wanaku-tool-service-kafka
```

Now, check if the services registered themselves, so that Wanaku can find them: 

```shell
wanaku targets tools list
```

Expected result: 

```
erviceType   port service    host      id
TOOL_INVOKER 9000 http       10.89.5.4 621c9f5b-050d-4063-8929-df9bc503c9c2
TOOL_INVOKER 9000 kafka      10.89.5.7 ca676b7f-1cec-4b64-b43b-d171d398bf7e
TOOL_INVOKER 9000 tavily     10.89.5.6 274b98cf-0cf1-497a-a3e9-01785e136651
TOOL_INVOKER 9000 camel-yaml 10.89.5.5 66384417-8f32-4c55-ba7b-82add824bbc5
```

This means that Wanaku is fully up and running, and the downstream services registered themselves with the router.

At this point, you can open the UI in your browser. Wanaku listens at http://localhost:8080/ by default. 



# Stop Wanaku
Make sure the `wanaku/stop-and-cleanup.sh` file is executable. If needed:
```shell
cd wanaku
chmod +x stop-and-cleanup.sh
```

Stop and remove the containers.

```shell
cd wanaku
./stop-and-cleanup.sh
```