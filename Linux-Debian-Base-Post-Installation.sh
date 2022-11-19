#!/bin/bash
# ----------------------------- Variables ----------------------------- #
#DIR
DIR_DOWNLOADS="/tmp/shell_programs/"
DIR_JETBRAINS="/opt/jetbrains-toolbox"
DIR_SSH="$HOME/.ssh"

#Version
JETBRAIN_VERSION="jetbrains-toolbox-1.26.5.13419"

#URL
URL_INTELLIJ="https://download.jetbrains.com/toolbox/"$JETBRAIN_VERSION".tar.gz"

#List Programs
PROGRAMS_APT=(
	git-all
  zsh
  curl
  vim
	maven 
)

PROGRAMS_FLATPAK=(
	com.visualstudio.code
	org.flameshot.Flameshot
)
# ---------------------------------------------------------------------- #

# ------------------------------ Required ------------------------------ #
## Unlock files from apt ##
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

## Update Repository ##
sudo apt update -y

## Install flatpak
echo "Installing flatpak...."
sudo apt install -y flatpak

## Add flathub for flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

## Update repositories ##
sudo apt update -y

## Create and prepare directories ##
sudo mkdir "$DIR_DOWNLOADS"
sudo mkdir "$DIR_JETBRAINS"
sudo mkdir "$DIR_SSH"
sudo chmod 700 $DIR_SSH

## Download and install external programs ##
sudo wget -c "$URL_INTELLIJ" -P "$DIR_DOWNLOADS"
# ---------------------------------------------------------------------- #

# ----------------------------- Execution ------------------------------ #
sudo apt upgrade -y

## Install apt programs ##
for program_apt in ${PROGRAMS_APT[@]}; do
  if ! dpkg -l | grep -q $program_apt; then # Only install if does not exist
    echo "Installing apt -> $program_apt...."
    sudo apt install -y "$program_apt"
  else
    echo "[Installed] - $program_apt"
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
## Jetbrains ##
echo "Installing jetbrains...."
sudo tar -xzf ${DIR_DOWNLOADS}${JETBRAIN_VERSION}.tar.gz -C ${DIR_JETBRAINS} --strip-components=1
sudo tar -xzf ${DIR_DOWNLOADS}${JETBRAIN_VERSION}.tar.gz -C ${DIR_DOWNLOADS}
cd ${DIR_DOWNLOADS}${JETBRAIN_VERSION} && ./jetbrains-toolbox

## ohMyZsh ##
echo "Installing OhMyZsh...."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sudo chsh -s $(which zsh)

## plugins zsh ##
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting
echo -e '\n #plugins=( git zsh-autosuggestions zsh-syntax-highlighting )' >> $HOME/.zshrc

## asdf ##
echo "Installing asdf...."
git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf
echo -e '\n. $HOME/.asdf/asdf.sh' >> $HOME/.zshrc

## plugins asdf ##
# Java
asdf plugin-add java https://github.com/halcyon/asdf-java.git
asdf install java openjdk-18.0.2
asdf global java openjdk-18.0.2

# Python
asdf plugin-add python https://github.com/asdf-community/asdf-python.git
asdf install python 3.10.7
asdf global python 3.10.7
# ---------------------------------------------------------------------- #

# ------------------------- Post-Installations ------------------------- #
## Conclude, update and clean ##
sudo apt update && sudo apt dist-upgrade -y
sudo apt autoclean -y
sudo apt autoremove -y
# ---------------------------------------------------------------------- #
