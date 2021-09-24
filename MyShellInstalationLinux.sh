#!/bin/bash
# ----------------------------- Variables ----------------------------- #
PPA_JAVA="ppa:openjdk-r/ppa"

URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_INTELLIJ="https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.20.8804.tar.gz"

JETBRAIN_VERSION="jetbrains-toolbox-1.21.9712"

DIR_DOWNLOADS="$HOME/Downloads/programs"

PROGRAMS_INSTALL=(
	git-all
	zsh 
	vim 
	maven 
	openjdk-15-jdk 
	openjdk-15-jre 
	snapd
)
# ---------------------------------------------------------------------- #

# ----------------------------- Required ----------------------------- #
## Unlock files from apt ##
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

## Update Repository ##
sudo apt update -y

## Add external repositories ##
sudo apt-add-repository "$PPA_JAVA" -y

# ---------------------------------------------------------------------- #

# ----------------------------- Execution ----------------------------- #
## Update repositories ##
sudo apt update -y


## Download and install external programs ##
mkdir "$DIR_DOWNLOADS"
wget -c "$URL_GOOGLE_CHROME" -P "$DIR_DOWNLOADS"
wget -c "$URL_INTELLIJ" -P "$DIR_DOWNLOADS"


## Install packages .deb download before ##
sudo dpkg -i $DIR_DOWNLOADS/*.deb


# Install apt programs
for program_name in ${PROGRAMS_INSTALL[@]}; do
  if ! dpkg -l | grep -q $program_name; then # Only install if does not exist
    sudo apt install "$program_name" -y
  else
    echo "[Installed] - $program_name"
  fi
done


## Install flatpak packages ##
#flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
#flatpak install flathub com.visualstudio.code


## Install Jetbrains packages ##
sudo tar -xzf ${JETBRAIN_VERSION}.tar.gz -C /opt
DIR_JETBRAINS="/opt/jetbrains-toolbox"
if mkdir ${DIR_JETBRAINS}; then
    sudo tar -xzf ${JETBRAIN_VERSION}.tar.gz -C ${DIR_JETBRAINS} --strip-components=1
fi

# ---------------------------------------------------------------------- #

# ----------------------------- Post-Installations #----------------------------- #
## Conclude, update and clean ##
sudo apt update && sudo apt dist-upgrade -y
#flatpak update
sudo apt autoclean
sudo apt autoremove -y
# ---------------------------------------------------------------------- #
