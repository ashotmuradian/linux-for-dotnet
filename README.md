# Setting up Fedora Linux for .NET Development

<!-- TOC -->
* [Setting up Fedora Linux for .NET Development](#setting-up-fedora-linux-for-net-development)
  * [Linux and Linux Tools](#linux-and-linux-tools)
  * [Git](#git)
  * [.NET](#net)
    * [Installation using package manager](#installation-using-package-manager)
    * [Installation using `dotnet-install` script](#installation-using-dotnet-install-script)
  * [Azure CLI](#azure-cli)
  * [VS Code](#vs-code)
  * [VS Code Extensions](#vs-code-extensions)
  * [Terraform](#terraform)
  * [GNOME](#gnome)
  * [Bash and GNOME sessions](#bash-and-gnome-sessions)
  * [JetBrains Tools](#jetbrains-tools)
  * [Increase Limit of Maximum Number of Open Files](#increase-limit-of-maximum-number-of-open-files)
  * [Increase Limit of Maximum Number of Open Sockets for NPM](#increase-limit-of-maximum-number-of-open-sockets-for-npm)
  * [Chromium-based Preferred Platform Backend](#chromium-based-preferred-platform-backend)
    * [Chrome](#chrome)
    * [Others](#others)
  * [Fonts](#fonts)
  * [Links](#links)
<!-- TOC -->

## Linux and Linux Tools

Install latest Linux distribution updates:

> Note: before upgrading the Linux distribution,
> to use a mirror list which has a higher bandwidth,
> override the GeoIP checks in the URLs of the Fedora repository files,
> in each of the `/etc/yum.repos.d/fedora*.repo` files,
> add or set the `country` URL query string parameter
> to a proper 2-letter ISO country code, keep in mind,
> your particular country may be not the one that provides a mirror list
> having highest bandwidth,
> [read more here](https://fedoraproject.org/wiki/Infrastructure/MirrorManager#Additional_options).

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

## Git

Configure Git to ensure line endings in files you checkout are correct for Linux.

```bash
git config --global core.autocrlf input
git config --global user.email "<EMAIL>"
git config --global core.name "<NAME>"
```

## .NET

### Installation using package manager

Install .NET SDKs:

```bash
sudo dnf install \
  dotnet-sdk-6.0 \
  dotnet-sdk-7.0 \
  dotnet-sdk-8.0
```

Install the managed symbol (pdb) files useful to debug the .NET SDK, .NET Runtime and ASP.NET Core runtime themselves:

```bash
sudo dnf install \
  dotnet-sdk-dbg-8.0 \
  dotnet-runtime-dbg-8.0 \
  aspnetcore-runtime-dbg-8.0
```

> Note: the symbol files provide you with an ability to not only debug the .NET SDK itself
> but also to navigate through the .NET source code during development. Install them if you
> wish Rider to navigate you to the source code files of .NET types instead of decompiled ones.

Install the archives of collections of packages needed to build the .NET SDK itself (optional):

```bash
sudo dnf install \
  dotnet-sdk-6.0-source-built-artifacts \
  dotnet-sdk-7.0-source-built-artifacts \
  dotnet-sdk-8.0-source-built-artifacts
```

> Note: install these packages if you build the .NET SDK itself from the source code.

Install workloads (optional):

```bash
dotnet workload update
dotnet workload install aspire
dotnet workload install android
dotnet workload install maui-android
dotnet workload install wasm-tools
```

### Installation using `dotnet-install` script

Alternatively, use the `dotnet-install` script to install the .NET SDKs.

```bash
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --channel 6.0
./dotnet-install.sh --channel 7.0
./dotnet-install.sh --channel 8.0
```

> Note: the `dotnet` command becomes available after [configuring PATH environment variable](#bash-and-gnome-sessions).

Install particular .NET SDK versions (optional):

```bash
./dotnet-install.sh --version 8.0.100
./dotnet-install.sh --version 8.0.101
./dotnet-install.sh --version 8.0.102
./dotnet-install.sh --version 8.0.103
./dotnet-install.sh --version 8.0.200
./dotnet-install.sh --version 8.0.201
./dotnet-install.sh --version 8.0.202
./dotnet-install.sh --version 8.0.203
./dotnet-install.sh --version 8.0.204
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
code --install-extension ms-graph.kiota
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
code --install-extension vitest.explorer
```

## Terraform

```bash
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf install terraform
terraform -install-autocomplete
```

## GNOME

Enable _Minimize_, _Maximize_ and _Close_ window buttons.

```
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
```

> Note how the colon ':' symbol defines the layout:
> - `:minimize,maximize,close`  - place buttons on the right side.
> - `close,minimize,maximize:`  - place buttons on the left side.
> - `close:minimize,maximize`  - mixed placement.

## Bash and GNOME sessions

Configure environment variables in `~/.bashrc`:

```bash
# Uncomment if the .NET SDK was installed using the dotnet-install script.
#function _dotnet_bash_complete()
#{
#  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
#  local candidates
#
#  read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)
#
#  read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
#}

export JAVA_HOME="$HOME/.jdks/jdk-20.0.1"
if [ -d "$JAVA_HOME/bin" ] ; then
    export PATH="$JAVA_HOME/bin:$PATH"
fi

export DOTNET_CLI_TELEMETRY_OPTOUT="1"

# Uncomment if the .NET SDK was installed using the dotnet-install script.
#export DOTNET_ROOT="$HOME/.dotnet"
#if [ -d $DOTNET_ROOT ] ; then
#    export PATH="$DOTNET_ROOT:$PATH"
#    
#    complete -f -F _dotnet_bash_complete dotnet
#fi
#
#if [ -d "$DOTNET_ROOT/tools" ] ; then
#    export PATH="$DOTNET_ROOT/tools:$PATH"
#fi

export NODE_PATH="$HOME/.node/bin"
if [ -d $NODE_PATH ] ; then
    export PATH="$NODE_PATH:$PATH"
fi

export GOPATH="$HOME/.go/go1.20/bin"
if [ -d $GOPATH ] ; then
    export PATH="$GOPATH:$PATH"
fi

export PROTOC_PATH="$HOME/.protoc/protoc-27.2-linux-x86_64/bin"
if [ -d $PROTOC_PATH ]; then
    export PATH="$PROTOC_PATH:$PATH"
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

## Chromium-based Preferred Platform Backend

### Chrome

When using Wayland and opening sencond Chrome instance in incognito mode it causes lags
in other Chrome instance, possibly even system-wide lags can be observed. To fix this
issue set `Preferred Ozone platform` Chrome flag to `Auto`.

```
chrome://flags/#ozone-platform-hint
```

### Others

To improve other Chromium-based applications perfromance edit their respective `.desktop` files
either in `/usr/share/applications` or `~/.local/share/applications` directory
so that ` --enable-features=UseOzonePlatform --ozone-platform=auto` are passed as parameters
to the executable files.

Here is an example for `VS Code` and `Lens`:

```
# /usr/share/applications/code.desktop
# ...
Exec=/usr/share/code/code --enable-features=UseOzonePlatform --ozone-platform=auto %F
# ...
```

```
# /usr/share/applications/lens-desktop.desktop
# ...
Exec=/opt/Lens/lens-desktop --enable-features=UseOzonePlatform --ozone-platform=auto %U
# ...
```

## Fonts

- Copy a `C:\Windows\Fonts` directory to `/usr/share/fonts/microsoft-fonts`.
- Download [Google Fonts](https://fonts.google.com/), extract and copy files to `/usr/share/fonts/google-fonts`.
- Set appropriate font directories and files permissions and re-generate fonts cache.
  ```bash
  sudo chmod 644 /usr/share/fonts/microsoft-fonts/*
  sudo chmod 644 /usr/share/fonts/google-fonts/*
  fc-cache -fv
  fc-cache-32 -fv
  sudo dnf install gnome-tweaks
  ```
- Run `gnome-tweaks` and configure font rendering settings under the _Fonts_ section.
  - Hinting: `Full`.
  - Antialiasing: `Subpixel`.

## Links

- [Install .NET](https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual)
- [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf)
- [Install VS Code](https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions)
- [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [Install kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm)
- [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm)
- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Install Docker Engine on Fedora](https://docs.docker.com/engine/install/fedora/)
- [dotnet autocomplete](https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete)
- [kubectl autocomplete](https://kubernetes.io/docs/reference/kubectl/quick-reference/#kubectl-autocomplete)
- [terraform autocomplete](https://developer.hashicorp.com/terraform/cli/commands#shell-tab-completion)
- [Install Microsoft Fonts](https://wiki.archlinux.org/title/Microsoft_fonts)
