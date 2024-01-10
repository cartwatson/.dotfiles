###############################################################################
#
# Init new systems with config files
#
###############################################################################

# function to ask user y/n questions
# credit to bartekspitza on github
function ask() {
    read -p "$1 (Y/n): " resp
    if [ -z "$resp" ]; then
        response_lc="y" # empty is Yes
    else
        response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
    fi

    [ "$response_lc" = "y" ]
}

# create folders
mkdir ~/personal
mkdir ~/work

# clone index
if ask "Would you like to clone The Index to ~/personal?"; then
    # git clone git@github.com:cartwatson/second-brain ~/personal/index
    git clone https://github.com/cartwatson/second-brain ~/personal/index
fi

# hush login
touch /home/$(whoami)/.hushlogin

# create backups
mv ~/.bashrc ~/.bashrc.old

# create symlinks for files
ln -s ~/.dotfiles/bashrc.sh          ~/.bashrc
ln -s ~/.dotfiles/aliases.sh         ~/.bash_aliases
ln -s ~/.dotfiles/vimrc.vim          ~/.vimrc
ln -s ~/.dotfiles/gitconfig-personal ~/.gitconfig
ln    ~/.dotfiles/gitconfig-personal ~/work/.gitconfig # not a symlink but thats on purpose

# dynamically create machine specific aliases
if ask "Create .machine_aliases?"; then
    touch ~/.machine_aliases.sh

    # windows/wsl instance specific aliases
    if ask "Is this a wsl instance?"; then
	echo "adding aliases for vscode 'c' and file explorer 'e'..." 
	cat ./wsl.sh >> ~/.machine_aliases.sh

	# vscode extensions
	if ask "Would you like to install vscode extensions?"; then
	    code --install-extension ms-vscode-remote.remote-wsl  # wsl extension
	    code --install-extension ritwickdey.liveserver        # live server
	    code --install-extension yzhang.markdown-all-in-one   # markdown all in one
	    code --install-extension pkief.material-icon-theme    # material icon theme
	fi
    fi
fi

# finalize
source ~/.bashrc

