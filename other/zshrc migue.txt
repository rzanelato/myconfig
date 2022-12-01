# Zshrc:
#   1) ZSH
#   2) Zplug
#   3) Tools
#   4) Aliases
#   5) External

# Requirements:
# - Packages: 'git', 'fzf'
# - Fonts: 'Nerd Fonts'

#--------#
# 1) ZSH #
#--------#

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000   # Lines in memory
SAVEHIST=100000   # Lines in disk
setopt EXTENDED_HISTORY   # Add timestamps to history
setopt APPEND_HISTORY     # Append history instead of replace
setopt INC_APPEND_HISTORY # Append command inmediately is entered
setopt HIST_IGNORE_SPACE  # Do not remember commands that start with a whitespace

# General options
setopt CORRECT            # Suggest command corrections
setopt IGNORE_EOF         # Explicit exit with 'logout' or 'exit'
setopt AUTO_CD            # Change directory by typing directory name

# Bindkeys
# To show current bindkeys run: bindkey
# To get shortcuts run: cat -v (and press whatever)
bindkey '^[[3~' delete-char         # Del: delete character
bindkey '^H' vi-backward-kill-word  # Ctrl + Backspace: delete word
bindkey '^[[3;5~' delete-word       # Ctrl + Del: delete word alternative
bindkey '^[[1;5C' forward-word      # Ctrl + Left Arrow: go to the beginning of word
bindkey '^[[1;5D' backward-word     # Ctrl + Right Arrow: go to the end of word
bindkey '^K' vi-kill-line           # Ctrl + K: delete line
bindkey '^[[H' beginning-of-line    # Home: go to the beginning of line
bindkey '^[[1~' beginning-of-line   # Home: go to the beginning of line in Tmux
bindkey '^[[F' end-of-line          # End: go to the end of line
bindkey '^[[4~' end-of-line         # End: go to the end of line in Tmux
bindkey '^R' history-incremental-search-backward  # Ctrl + R: search history in Tmux
bindkey -s '^P' '/usr/local/bin/tmux-window\n'  # Ctrl + P: fuzzy search to find Tmux windows

# Completion
zstyle ':completion:*' menu select  # Show interactive menu to select directory
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'  # CD with autocompletion

# Disable 'Ctrl-s'
stty -ixon

#----------#
# 2) Zplug #
#----------#

# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
    source ~/.zplug/init.zsh && zplug update --self
fi

# Load zplug
source ~/.zplug/init.zsh

# Theme
zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme, as:theme

# Plugins
zplug "plugins/pj", from:oh-my-zsh    # Projects jump directly
zplug "plugins/bundler", from:oh-my-zsh   # Bundler completions
zplug "plugins/dotenv", from:oh-my-zsh    # Automatically load variables from .env file
zplug "plugins/docker-compose", from:oh-my-zsh    # Docker Compose completions
zplug "plugins/golang", from:oh-my-zsh, ignore:oh-my-zsh.sh, defer:3   # Golang completions
zplug "plugins/pip", from:oh-my-zsh   # Pip completions
zplug "plugins/terraform", from:oh-my-zsh   # Terraform completions
zplug "rupa/z", use:z.sh              # Directories jump based on frecency
zplug "changyuheng/fz", defer:1       # Fuzzy search to tab completion of z
zplug "junegunn/fzf", use:shell/key-bindings.zsh  # Ctrl+R using fuzzy search
zplug "tmuxinator/tmuxinator", use:"completion/tmuxinator.zsh"  # Tmuxinator completions
zplug "lukechilds/zsh-better-npm-completion", defer:2   # NPM completions
zplug "zsh-users/zsh-autosuggestions", defer:2       # Fish-like autosuggestions
zplug "zsh-users/zsh-syntax-highlighting", defer:3   # Fish-like syntax highlighting

# Install plugins
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# Load plugins
zplug load

# Plugins Configuration

#------ Powerlevel9k Theme ------#
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  root_indicator
  host
  dir
  custom_ruby
  custom_terraform
  custom_virtualenv
  vcs
)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status
  command_execution_time
)
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="╰─> "
POWERLEVEL9K_SSH_ICON="\uf489"
POWERLEVEL9K_DIR_HOME_BACKGROUND='darkcyan'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='darkcyan'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='darkcyan'
POWERLEVEL9K_DIR_ETC_BACKGROUND='darkcyan'
POWERLEVEL9K_CARRIAGE_RETURN_ICON="\u2718"
POWERLEVEL9K_EXECUTION_TIME_ICON="\uf251"
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=1
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='black'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='white'
POWERLEVEL9K_VCS_BRANCH_ICON="\uf126"
POWERLEVEL9K_VCS_GIT_GITHUB_ICON="\uf113"
POWERLEVEL9K_VCS_GIT_GITLAB_ICON="\uf296"

custom_ruby() {
  [[ ! -f "Gemfile" ]] && return
  echo -n "\ue739 $RUBY_VERSION"
}
POWERLEVEL9K_CUSTOM_RUBY='custom_ruby'
POWERLEVEL9K_CUSTOM_RUBY_BACKGROUND='red'

custom_terraform() {
  [[ ! -d ".terraform" ]] && return
  echo -n "\ue5fc $(terraform workspace show)"
}
POWERLEVEL9K_CUSTOM_TERRAFORM='custom_terraform'
POWERLEVEL9K_CUSTOM_TERRAFORM_BACKGROUND='grey74'

custom_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ "$virtualenv_path" ]]; then
    echo -n "\ue235 ${virtualenv_path:t}"
  elif [[ -f "requirements.txt" || -f "setup.py" || -d ".venv" ]]; then
    echo -n "\ue235"
  fi
}
POWERLEVEL9K_CUSTOM_VIRTUALENV='custom_virtualenv'
POWERLEVEL9K_CUSTOM_VIRTUALENV_BACKGROUND='blue'

#------ PJ ------#
PROJECT_PATHS=($HOME/Workspace $HOME/Workspace/repos)
c() {
  pj $@
}


#----------#
# 3) Tools #
#----------#

#------- asdf ------#
[ -f /opt/asdf-vm/asdf.sh ] && source /opt/asdf-vm/asdf.sh

#------- AWS ------#
[ -f /usr/bin/aws_zsh_completer.sh ] && source /usr/bin/aws_zsh_completer.sh

#------- C --------#
export MAKEFLAGS="-j$(($(nproc)+1))"

#-- DigitalOcean --#
[ -f $HOME/.asdf/shims/doctl ] && source <(doctl completion zsh)

#----- Docker -----#
dockexec() {
  docker exec -it $(docker ps --format '{{.Names}}' | fzf) ${1:-sh}
}

#-- Google Cloud --#
[ -f /opt/google-cloud-sdk/completion.zsh.inc ] && source /opt/google-cloud-sdk/completion.zsh.inc

#------- Go -------#
export GOPATH="$HOME/.go"

#----- Python -----#
if [[ ! -f $HOME/.pythonrc ]]; then
  echo "import rlcompleter, readline" >> $HOME/.pythonrc
  echo "readline.parse_and_bind('tab:complete')" >> $HOME/.pythonrc
fi

export PYTHONSTARTUP=$HOME/.pythonrc

#------ SSH ------#
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

#----- Tmux ------#
if [[ ! -f /usr/local/bin/tmux-window ]]; then
  echo "#! /bin/bash" >> /usr/local/bin/tmux-window
  echo "tmux select-window -t\$(tmux list-sessions | grep attached | cut -d ':' -f1):\$(tmux list-windows | fzf | cut -d ':' -f1)" >> /usr/local/bin/tmux-window
  chmod +x /usr/local/bin/tmux-window || echo "Permissions issues to add tmux-window"
fi

#------ Vim ------#
export EDITOR=vim


#------------#
# 4) Aliases #
#------------#

# Basics
alias ls='ls --color=auto'
alias la='ls -a --color=auto'
alias ll='ls -l --color=auto'
alias l='ls -la --color=auto'
alias grep='grep --color=auto'
alias md='mkdir -p'
alias df='df -h'
alias free='free -m'
alias vi='vim'
alias path='echo -e "${PATH//:/\n}"'
alias ...='cd ../../'
alias ....='cd ../../../'
alias please='sudo'

# Utils
alias dot="$HOME/.dotfiles"
alias h='fc -lt "| %d-%m-%Y %H:%M:%S |" 1'  # Pretty history output
alias pubkey='more ~/.ssh/id_rsa.pub | xclip -selection clipboard | echo '\''=> Public key copied to pasteboard.'\' # Get publick key
alias clip='xclip -selection clipboard' # Copy to clipboard
lowercase() { awk '{print tolower($0)}' }
uppercase() { awk '{print toupper($0)}' }
json() { jq -r | python -m json.tool | jq $1 }

# Powerlevel9k Theme
alias theme-down='prompt_powerlevel9k_teardown'
alias theme-up='prompt_powerlevel9k_setup'

# Manjaro/Pacman
alias pacman-clean='sudo pacman -Sc'
alias pacman-list-date='expac --timefmt="%Y-%m-%d %T" "%l\t%n" | sort'
alias pacman-list-size='expac -H M "%011m\t%-20n\t%10d" $(comm -23 <(pacman -Qqen | sort) <(pacman -Qqg base base-devel | sort)) | sort -n'
alias pacman-remove='sudo pacman -Rsdn $(pacman -Qqdt)'

# Git
alias gcl='git clone --recurse-submodules'
alias gst='git status'
alias gb='git branch'
alias gba='git branch -a'
alias grv='git remote -v'
alias gd='git diff'
alias gdf='git diff --name-only'
alias gl='git log --graph'
alias glf='git log --graph --stat'
alias glo='git log --graph --oneline'
alias ga='git add .'
alias gco='git commit -m'
alias gca='git commit --amend'
alias gca!='git commit --amend --no-edit'
alias gsta='git stash'
alias gstl='git stash list'
alias gstp='git stash pop'
alias grs='git reset --soft HEAD~1'
alias grh='git reset --hard HEAD~1'
alias gp='git pull'
alias gpom='git pull origin master'
alias gpod='git pull origin devel'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbd='git rebase devel'
alias grbm='git rebase master'
alias gbda='git branch --no-color --merged | command grep -vE "^(\*|\s*(master|release|develop|dev|devel)\s*$)" | command xargs -n 1 git branch -d' # Delete merged branches
alias gcd='git checkout devel'
alias gcm='git checkout master'
alias gcb='git checkout -b'
gc() { # Git checkout
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
gcr() { # Git checkout (remotes included)
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Python
alias pipr='pip install -r requirements.txt'
alias venv='source .venv/bin/activate'
venvc() {
  virtualenv -p python3 .venv && source .venv/bin/activate
  [ -f requirements.txt ] && pip install -r requirements.txt
  [ -f test_requirements.txt ] && pip install -r test_requirements.txt
}

# Docker
alias d='docker'
alias dr='docker run --rm -it'
alias dp='docker ps'
alias dpa='docker ps -a'
alias dpw='watch -n 1 -d docker ps'
alias drm='docker container prune'
alias di='docker image ls'
alias dip='docker image prune'
alias dirm='docker image rm'
alias dn='docker network ls'
alias dnp='docker network prune'
alias dnrm='docker network rm'
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down -v'
alias dse='docker service ls'
alias dsep='docker service ps'
alias dsel='docker service logs -f'
alias dseu='docker service update --force'
alias dst='docker stack ls'
alias dstd='docker stack deploy -c docker-compose.yml'
alias dstrm='docker stack rm'

# Kubernetes
alias k='kubectl'
alias ka='kubectl apply -f'
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgpo='kubectl get pods -o wide'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kgs='kubectl get services'
alias kc='kubectl config'
alias kcc='kubectl config current-context'
alias kcu='kubectl config use-context'
alias kcgc='kubectl config get-contexts'
alias kcv='kubectl config view'

# Terraform
alias t='terraform'
alias ti='terraform init'
alias tir='terraform init --reconfigure'
alias tp='terraform plan'
alias tf='terraform fmt'
alias tfc='terraform fmt -check'
alias tv='terraform validate'
alias ta='terraform apply'
alias tat='terraform apply -target='
alias ta!='terraform apply -auto-approve'
alias twl='terraform workspace list'
alias twn='terraform workspace new'
alias tws='terraform workspace select'
alias tsl='terraform state list'
alias tss='terraform state show'
alias tsp='terraform state pull'
alias tsr='terraform state rm'
alias tt='terraform taint'

#-------------#
# 5) External #
#-------------#

if [[ -f $HOME/.zshrc.local ]]; then
    source $HOME/.zshrc.local
fi
