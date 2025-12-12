#!/bin/bash
###############################################################################
# DinVM - Threat Intelligence Virtual Machine Installer
# Author: Dinesh (DinIntel)
# Version: v1.0
# Base OS: Linux Lite 6.6 / Ubuntu 22.04+
###############################################################################

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
END="\e[0m"

echo -e "${GREEN}
██████╗ ██╗███╗   ██╗██╗██╗   ██╗███╗   ███╗
██╔══██╗██║████╗  ██║██║██║   ██║████╗ ████║
██████╔╝██║██╔██╗ ██║██║██║   ██║██╔████╔██║
██╔══██╗██║██║╚██╗██║██║██║   ██║██║╚██╔╝██║
██║  ██║██║██║ ╚████║██║╚██████╔╝██║ ╚═╝ ██║
╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝     ╚═╝
${END}"
echo -e "${YELLOW}      DinVM — Threat Intelligence Virtual Machine Installer${END}"
echo ""

sleep 2

###############################################################################
# 0. Root check
###############################################################################
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] Please run as root: sudo bash dinvm.sh${END}"
   exit 1
fi

###############################################################################
# 1. Update System
###############################################################################
echo -e "${GREEN}[1/15] Updating system ...${END}"
apt update && apt upgrade -y

###############################################################################
# 2. Install Core Threat Intel Packages
###############################################################################
echo -e "${GREEN}[2/15] Installing core TI tools ...${END}"

apt install -y \
  curl wget git python3 python3-pip python3-venv \
  neo4j tor torsocks whois dnsutils jq yq \
  nmap tcpdump net-tools htop tmux traceroute \
  sqlite3 unzip zip ufw gufw docker.io docker-compose \
  graphviz build-essential libffi-dev libssl-dev

###############################################################################
# 3. OSINT Tools
###############################################################################
echo -e "${GREEN}[3/15] Installing OSINT tools ...${END}"

pip3 install --upgrade \
  theHarvester \
  shodan \
  censys \
  whiskeybuffet \
  spiderfoot \
  emailfinder \
  holehe \
  sherlock-project \
  onyphe \
  intelowl-cli \
  opsec

###############################################################################
# 4. Install Amass
###############################################################################
echo -e "${GREEN}[4/15] Installing Amass ...${END}"
snap install amass --classic

###############################################################################
# 5. Malware / IOC Tools
###############################################################################
echo -e "${GREEN}[5/15] Installing IOC tools ...${END}"

pip3 install \
  yara-python \
  vt-py \
  mwdblib \
  stix2 \
  taxii2-client \
  sigma-cli \
  python-misp

###############################################################################
# 6. Threat Intel Platforms (OpenCTI-ready)
###############################################################################
echo -e "${GREEN}[6/15] Preparing OpenCTI environment ...${END}"

mkdir -p /opt/dinvm/opencti
cd /opt/dinvm/opencti
curl -sSL https://raw.githubusercontent.com/OpenCTI-Platform/docker/main/docker-compose.yml -o docker-compose.yml

###############################################################################
# 7. Neo4j Config
###############################################################################
echo -e "${GREEN}[7/15] Configuring Neo4j ...${END}"

systemctl enable neo4j
systemctl start neo4j

###############################################################################
# 8. AI Toolkit (Local + Cloud)
###############################################################################
echo -e "${GREEN}[8/15] Installing AI toolkit ...${END}"

pip3 install \
  transformers \
  sentence-transformers \
  openai \
  langchain \
  unstructured \
  faiss-cpu

###############################################################################
# 9. Tor & Dark Web Safe Mode
###############################################################################
echo -e "${GREEN}[9/15] Activating Tor Safe Mode ...${END}"

systemctl enable tor
systemctl start tor

echo "SOCKS5=127.0.0.1:9050" > /etc/profile.d/torproxy.sh

###############################################################################
# 10. DinVM Branding (Wallpaper + Themes)
###############################################################################
echo -e "${GREEN}[10/15] Applying DinVM branding ...${END}"

mkdir -p /usr/share/dinvm

# default wallpaper
cat <<EOF >/usr/share/dinvm/dinvm-wallpaper.txt
(DinVM Wallpaper Placeholder)
EOF

# XFCE background
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "/usr/share/dinvm/dinvm-wallpaper.txt"

###############################################################################
# 11. Create DinVM Menu Folder
###############################################################################
echo -e "${GREEN}[11/15] Creating TI tool launchers ...${END}"

mkdir -p /usr/share/applications/dinvm

# Sample launcher
cat <<EOF >/usr/share/applications/dinvm/tor-browser.desktop
[Desktop Entry]
Name=Tor Browser
Exec=torbrowser-launcher
Type=Application
Categories=Network;Security;
EOF

###############################################################################
# 12. Add DinVM Commands
###############################################################################
echo -e "${GREEN}[12/15] Creating DinVM commands ...${END}"

cat <<EOF >/usr/bin/dinvm-update
#!/bin/bash
curl -sSL https://raw.githubusercontent.com/DinIntel/DinVM/main/dinvm.sh | bash
EOF

chmod +x /usr/bin/dinvm-update

###############################################################################
# 13. Cleanup
###############################################################################
echo -e "${GREEN}[13/15] Cleaning up ...${END}"
apt autoremove -y
apt clean

###############################################################################
# 14. Final Message
###############################################################################
echo -e "${GREEN}DinVM installed successfully! Reboot your system.${END}"
echo ""
echo "Run:  sudo reboot"
