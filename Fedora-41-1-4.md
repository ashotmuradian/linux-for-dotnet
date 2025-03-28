# Fedora 41.1.4

```sh
gsettings set org.gnome.software download-updates false
gsettings set org.gnome.software download-updates-notify false
gsettings set org.gnome.desktop.search-providers disable-external true
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.keyboard delay 150
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 10
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
```

```sh
echo "X-GNOME-Autostart-enabled=false" | sudo tee -a /etc/xdg/autostart/org.gnome.Software.desktop
```

```sh
sudo systemctl disable packagekit
```

```sh
sudo dnf upgrade -y
```

```sh
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
```

```sh
sudo dnf config-manager addrepo --from-repofile https://downloads.k8slens.dev/rpm/lens.repo
```

```sh
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
```

```sh
sudo dnf remove -y PackageKit-command-not-found
```

```sh
sudo dnf install -y \
  nss-tools \
  dnf-plugins-core \
  lstopo \
  perf \
  htop \
  fuse-libs \
  ./google-chrome-stable_current_x86_64.rpm dotnet-sdk-8.0 \
  code \
  lens \
  dotnet-sdk-8.0 \
  dotnet-sdk-dbg-8.0 \
  dotnet-runtime-dbg-8.0 \
  aspnetcore-runtime-dbg-8.0 \
  dotnet-sdk-8.0-source-built-artifacts
```

```sh
dotnet workload update
```
