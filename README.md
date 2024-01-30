# Setting up Fedora Linux for .NET Development

## ExpressVPN (optional)

This step is optional, but if you know in advance that
your ISP throttles your internet traffic,
or certain types of traffic, or it unable to take efficient routes,
or CDN location mismatch is huge,
then install VPN client before anything else,
otherwise distro update and the rest of the commands
are going to take ages to run.

> No ads, this doc is primarily for myself, there are quite a few good VPN service providers,
> this one just works well in my country.

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

Install Core Plugins for DNF:

```bash
sudo dnf install dnf-plugins-core
```

## .NET

```bash
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --channel 6.0
./dotnet-install.sh --channel 7.0
./dotnet-install.sh --channel 8.0
```

Install workloads (optional):

```bash
dotnet workload update
dotnet workload install aspire
dotnet workload install android
dotnet workload install maui-android
dotnet workload install wasm-tools
```

## Azure CLI

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
sudo dnf install azure-cli
az config set core.collect_telemetry=false
az config set core.allow_broker=false
```

## VS Code

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
sudo dnf install code
```

## VS Code Extensions

```bash
code --install-extension Angular.ng-template
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension GitHub.copilot
code --install-extension HashiCorp.HCL
code --install-extension HashiCorp.terraform
code --install-extension MS-vsliveshare.vsliveshare
code --install-extension Oracle.mysql-shell-for-vs-code
code --install-extension esbenp.prettier-vscode
code --install-extension figma.figma-vscode-extension
code --install-extension golang.Go
code --install-extension meta.relay
code --install-extension ms-azuretools.vscode-azureresourcegroups
code --install-extension ms-azuretools.vscode-azureterraform
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.csdevkit
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-mssql.data-workspace-vscode
code --install-extension ms-mssql.mssql
code --install-extension ms-mssql.sql-database-projects-vscode
code --install-extension ms-ossdata.vscode-postgresql
code --install-extension ms-toolsai.vscode-ai
code --install-extension ms-toolsai.vscode-ai-remote
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.hexeditor
code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension redhat.vscode-yaml
```

## Terraform

```bash
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf install terraform
terraform -install-autocomplete
```

## Bash and GNOME sessions

Configure environment variables in `~/.bashrc` and `~/.profile`:

```bash
function _dotnet_bash_complete()
{
  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
  local candidates

  read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)

  read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
}

export JAVA_HOME="$HOME/.jdks/jdk-20.0.1"
if [ -d "$JAVA_HOME/bin" ] ; then
    export PATH="$JAVA_HOME/bin:$PATH"
fi

export DOTNET_CLI_TELEMETRY_OPTOUT="1"

export DOTNET_ROOT="$HOME/.dotnet"
if [ -d $DOTNET_ROOT ] ; then
    export PATH="$DOTNET_ROOT:$PATH"
    
    complete -f -F _dotnet_bash_complete dotnet
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

if command -v terraform &> /dev/null
then
    alias tf=terraform
    complete -C "$(readlink -f terraform)" tf
    
    export TF_CLI_ARGS_plan='-parallelism=32'
    export TF_CLI_ARGS_apply='-parallelism=32'
fi

if command -v kubectl &> /dev/null
then
    source <(kubectl completion bash)
    
    alias k=kubectl
    complete -o default -F __start_kubectl k
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

## Links

- [Install .NET](https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual)
- [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf)
- [Install VS Code](https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions)
- [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Install Docker Engine on Fedora](https://docs.docker.com/engine/install/fedora/)
- [Install Docker Desktop on Fedora](https://docs.docker.com/desktop/install/fedora/)
- [dotnet autocomplete](https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete)
- [kubectl autocomplete](https://kubernetes.io/docs/reference/kubectl/quick-reference/#kubectl-autocomplete)
- [terraform autocomplete](https://developer.hashicorp.com/terraform/cli/commands#shell-tab-completion)

## Todo List

- [ ] kubectl installation
- [ ] Docker installation
  (prefer Docker Engine to Docker Desktop unless Kubernetes cluster is required to run in Docker)
- [ ] Chrome installation
- [ ] Edge installation
- [ ] Script to download Java and compare SHA256 hash sum
