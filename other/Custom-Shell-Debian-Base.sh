#!/bin/bash
# ----------------------------- Variables ----------------------------- #
#DIR
DIR_DOWNLOADS="$HOME/Downloads/programs/"
DIR_JETBRAINS="/opt/jetbrains-toolbox"

#Version
JETBRAIN_VERSION="jetbrains-toolbox-1.25.12627"

#URL
URL_INTELLIJ="https://download.jetbrains.com/toolbox/"$JETBRAIN_VERSION".tar.gz"

#PPA
PPA_JAVA="ppa:openjdk-r/ppa"

#List Programs
PROGRAMS_APT=(
	git-all
	maven 
	npm 
	openjdk-11-jdk
	snapd
  libfuse2
)

PROGRAMS_SNAP=(
	ngrok
)

PROGRAMS_FLATPAK=(
	com.getpostman.Postman
	org.flameshot.Flameshot
)
# ---------------------------------------------------------------------- #

# ------------------------------ Required ------------------------------ #
## Unlock files from apt ##
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

## Install curl
echo "Installing curl...."
sudo apt install curl

## Install flatpak
echo "Installing flatpak...."
sudo apt install -y flatpak

## Update Repository ##
sudo apt update -y

## Add external repositories ##
sudo apt-add-repository "$PPA_JAVA" -y

## Add flathub for flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

## Update repositories ##
sudo apt update -y

## Download and install external programs ##
sudo mkdir "$DIR_DOWNLOADS"
sudo mkdir "$DIR_JETBRAINS"

sudo wget -c "$URL_INTELLIJ" -P "$DIR_DOWNLOADS"

# ---------------------------------------------------------------------- #

# ----------------------------- Execution ------------------------------ #
## Install apt programs ##
for program_apt in ${PROGRAMS_APT[@]}; do
  if ! dpkg -l | grep -q $program_apt; then # Only install if does not exist
    echo "Installing apt -> $program_apt...."
    sudo apt install -y "$program_apt"
  else
    echo "[Installed] - $program_apt"
  fi
done

## Install snap programs ##
for program_snap in ${PROGRAMS_SNAP[@]}; do
  if ! snap list | grep -q $program_snap; then # Only install if does not exist
    echo "Installing snap -> $program_apt...."
    sudo snap install "$program_snap"
  else
    echo "[Installed] - $program_snap"
  fi
done

## Install flatpak programs ##
for program_flatpak in ${PROGRAMS_FLATPAK[@]}; do
  if ! flatpak list | grep -q $program_flatpak; then # Only install if does not exist
    echo "Installing flatpak -> $program_flatpak...."
    flatpak install flathub "$program_flatpak" --assumeyes
  else
    echo "[Installed] - $program_flatpak"
  fi
done

## ------ Specific installation ------ ##
## Http-echo-server ##
echo "Installing http-echo-server...."
sudo npm install http-echo-server -g

## Jetbrains ##
echo "Installing jetbrains...."
sudo tar -xzf ${DIR_DOWNLOADS}${JETBRAIN_VERSION}.tar.gz -C ${DIR_JETBRAINS} --strip-components=1
sudo tar -xzf ${DIR_DOWNLOADS}${JETBRAIN_VERSION}.tar.gz -C ${DIR_DOWNLOADS}
cd ${DIR_DOWNLOADS}${JETBRAIN_VERSION} && ./jetbrains-toolbox
# ---------------------------------------------------------------------- #

# ------------------------- Post-Installations ------------------------- #
## Conclude, update and clean ##
sudo apt update && sudo apt dist-upgrade -y
sudo apt autoclean
sudo apt autoremove -y
# ---------------------------------------------------------------------- #
