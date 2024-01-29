# Setting up Fedora Linux for .NET Development

## ExpressVPN

Download latest version from
[ExpressVPN Downloads](https://www.expressvpn.com/latest)
page.

Log into ExpressVPN account, copy activation key
from
[ExpressVPN Subscriptions](https://www.expressvpn.com/subscriptions)
page and activate ExpressVPN via:

```bash
expressvpn activate
```

Connect to VPN:

```bash
expressvpn connect smart
```

## Linux and Linux Tools

Install latest linux distribution updates:

```bash
sudo dnf upgrade
```

> Reboot, most probably the kernel version has been updated.

Install tools for the Network Security Services:

```bash
sudo dnf install nss-tools
```

## .NET

```bash
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --channel 6.0
./dotnet-install.sh --channel 7.0
./dotnet-install.sh --channel 8.0
```

[Enable tab completion for the .NET CLI](https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete)

## Bash and GNOME sessions

Configure environment variables in `~/.bashrc` and `~/.profile`:

```bash
export JAVA_HOME="$HOME/.jdks/jdk-20.0.1"
if [ -d "$JAVA_HOME/bin" ] ; then
    export PATH="$JAVA_HOME/bin:$PATH"
fi

export DOTNET_ROOT="$HOME/.dotnet"
if [ -d $DOTNET_ROOT ] ; then
    export PATH="$DOTNET_ROOT:$PATH"
fi

if [ -d "$DOTNET_ROOT/tools" ] ; then
    export PATH="$DOTNET_ROOT/tools:$PATH"
fi

export NODE_PATH="$HOME/.node/bin"
if [ -d $NODE_PATH ] ; then
    export PATH="$NODE_PATH:$PATH"
fi

export GOPATH="$HOME/.go/go1.20/bin"
if [ -d $GOPATH ] ; then
    export PATH="$GOPATH:$PATH"
fi

export NGROK_PATH="$HOME/.ngrok"
if [ -d $NGROK_PATH ] ; then
    export PATH="$NGROK_PATH:$PATH"
fi

export KUBE_CONFIG_PATH="$HOME/.kube/config"

export KUBE_EDITOR="code -w"

export EDITOR="code -w"

export NUGET_CONCURRENCY_LIMIT=32

ulimit -n 8192
```

## JetBrains Tools

Log into
[JetBrains account](https://account.jetbrains.com)
and download the Toolbox app.
Extract files from the downloaded archive and run `jetbrains-toolbox` executable.
Log into account in the Toolbox app.

> Note: set `Maximum Heap Size` configuration parameter of JetBrains tools in the Toolbox
> app to either `8192` or `16384`.

## Other Tools

Install VS Code, Chrome, Edge.

## Increase Limit of Maximum Number of Open Files

```bash
sudo nano /etc/security/limits.conf
```

```conf
*               soft    nofile            8192
*               hard    nofile            16384
```

## Increase Limit of Maximum Number of Open Sockets for NPM

```bash
npm -g config set maxsockets 32
```

## Todo List

- [ ] Add script to download Java and compare SHA256 hash sum