#!/bin/bash
# ----------------------------- Variables ----------------------------- #
#DIR
DIR_DOWNLOADS="/tmp/programs/"
DIR_JETBRAINS="/opt/jetbrains-toolbox"

#Version
JETBRAIN_VERSION="jetbrains-toolbox-1.25.12627"

#URL
URL_INTELLIJ="https://download.jetbrains.com/toolbox/"$JETBRAIN_VERSION".tar.gz"
URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

#PPA
PPA_JAVA="ppa:openjdk-r/ppa"

#List Programs
PROGRAMS_APT=(
	git-all
	zsh
	vim
	maven 
	openjdk-15-jdk 
	openjdk-15-jre
	snapd
  	libfuse2
)

PROGRAMS_FLATPAK=(
	com.visualstudio.code
	org.flameshot.Flameshot
)

# ---------------------------------------------------------------------- #

# ----------------------------- Required ----------------------------- #
## Unlock files from apt ##
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

## Install curl
sudo apt install curl

## Install flatpak
sudo apt install flatpak -y

## Update Repository ##
sudo apt update -y

## Add external repositories ##
sudo apt-add-repository "$PPA_JAVA" -y

## Add flathub for flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

## Update repositories ##
sudo apt update -y

## Prepare diretory ##
sudo mkdir "$DIR_DOWNLOADS"
sudo mkdir "$DIR_JETBRAINS"
# ---------------------------------------------------------------------- #

# ----------------------------- Execution ----------------------------- #



## Download and install external programs ##
sudo wget -c "$URL_GOOGLE_CHROME" -P "$DIR_DOWNLOADS"
sudo wget -c "$URL_INTELLIJ" -P "$DIR_DOWNLOADS"

## Install packages .deb download before ##
sudo dpkg -i $DIR_DOWNLOADS/*.deb


# Install apt programs
for program_apt in ${PROGRAMS_APT[@]}; do
  if ! dpkg -l | grep -q $program_apt; then # Only install if does not exist
    sudo apt install "$program_apt" -y
  else
    echo "[Installed] - $program_apt"
  fi
done

## Install flatpak programs ##
for program_flatpak in ${PROGRAMS_FLATPAK[@]}; do
  if ! flatpak list | grep -q $program_flatpak; then # Only install if does not exist
    flatpak install flathub "$program_flatpak" --assumeyes
  else
    echo "[Installed] - $program_flatpak"
  fi
done
# ---------------------------------------------------------------------- #

# --------------------------- Special Installations #--------------------------- #
## Jetbrains ##
sudo tar -xzf ${DIR_DOWNLOADS}${JETBRAIN_VERSION}.tar.gz -C ${DIR_JETBRAINS} --strip-components=1
sudo tar -xzf ${DIR_DOWNLOADS}${JETBRAIN_VERSION}.tar.gz -C ${DIR_DOWNLOADS}
cd ${DIR_DOWNLOADS}${JETBRAIN_VERSION} && ./jetbrains-toolbox

#ohmyzsh - https://github.com/ohmyzsh/ohmyzsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#asdf - https://asdf-vm.com/guide/getting-started.html
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

#zsh-syntax-highlighting -  https://github.com/zsh-users/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins

#zsh-autocomplete - https://github.com/marlonrichert/zsh-autocomplete
https://github.com/marlonrichert/zsh-autocomplete.git ~/.oh-my-zsh/plugins

# ---------------------------------------------------------------------- #

# ----------------------------- Post-Installations #----------------------------- #
## Conclude, update and clean ##
sudo apt update && sudo apt dist-upgrade -y
flatpak update
sudo apt autoclean
sudo apt autoremove -y
# ---------------------------------------------------------------------- #
