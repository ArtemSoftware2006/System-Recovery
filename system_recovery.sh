#!/bin/bash

echo_blue() {
  echo -e "\033[34m$1\033[0m"
}

echo_blue "Recovering system is starting now"
echo_blue "Please, run script via: sudo bash ...\nPress Y for continue"

read -n 1 -s key

if [[ "$key" != "Y" && "$key" != "y" ]]; then
    echo_blue "Abort..."
    exit 1
fi

if [ "$EUID" -ne 0 ]; then 
    echo_blue "ERROR: Script should be run from root"
    exit 1
fi

# Install Base Utils
echo_blue "Install base utils"

apt update
apt install vim curl traceroute nmap htop atop sysstat

# Install Base Applications
echo_blue "Install base apllications"

echo_blue "Obsidian Installl"

if command -v obsidian &> /dev/null; then
    echo "Obsidian already installed"
else
    curl -L -o obsidian_1.6.7_amd64.deb https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.7/obsidian_1.6.7_amd64.deb
    apt install -f ./obsidian_1.6.7_amd64.deb
    rm -f ./obsidian_1.6.7_amd64.deb
fi
# Install WPS Office

echo_blue "WPS Install"

if command -v wps-office &> /dev/null; then
    echo "WPS Office already installed"
else
    curl -L -o wps-office.deb https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11723/wps-office_11.1.0.11723.XA_amd64.deb
    apt install -f ./wps-office.deb
    rm -f ./wps-office.deb
fi

# Install Discord

echo_blue "Discord Install"

if command -v discord &> /dev/null; then
    echo "Discord already installed"
else
    curl -L -o discord.deb "https://discord.com/api/download/stable?platform=linux&format=deb"
    apt install -f ./discord.deb
    rm ./discord.deb
fi

# Install VS Cod
echo_blue "Install VS Code"

if command -v code &> /dev/null; then
    echo "VS Code already installed"
else
    apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg

    apt install apt-transport-https
    apt update
    apt install code # or code-insiders
fi

# Install Docker
echo_blue "Install Docker"

# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker Postinstall

echo_blue "Docker Postinstall (https://docs.docker.com/engine/install/linux-postinstall/)"

# Install KVM 

VIRT=$(lscpu | grep -E 'Вирт|Virt')

if [ -n "$VIRT" ]; then
    echo_blue "Virtualization is enablrd\n$VIRT\nInstall KVM"

    apt install qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager
    gpasswd -a $SUDO_USER libvirt
    systemctl status libvirtd

    echo_blue "More about KVM (https://losst.pro/ustanovka-kvm-ubuntu-16-04)"
else
    echo_blue "Virtualization is not enabled"    
fi
