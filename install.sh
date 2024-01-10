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
echo "Creating ~/personal and ~/work directories..."
if [ ! -d ~/personal ]; then
    mkdir ~/personal
fi
if [ ! -d ~/work ]; then
    mkdir ~/work
fi

# clone index
if ask "Would you like to clone The Index to ~/personal? "; then
    # assume clone via ssh is setup (how else did I get the dotfiles repo)
    git clone git@github.com:cartwatson/second-brain ~/personal/index
    # git clone https://github.com/cartwatson/second-brain ~/personal/index
fi

# hush login
if ask "Would you like to hush login messages? "; then
    touch /home/$(whoami)/.hushlogin
fi

# create backups
echo "Creating backup of bashrc to .bashrc.old ..."
if [ -f ~/.bashrc ]; then
    mv ~/.bashrc ~/.bashrc.old
fi

# create symlinks for files
echo "Creating symlinks for bashrc, aliases, vimconfig, and gitconfig..."
ln -s ~/.dotfiles/bashrc.sh          ~/.bashrc
ln -s ~/.dotfiles/aliases.sh         ~/.bash_aliases
ln -s ~/.dotfiles/vimrc.vim          ~/.vimrc
ln -s ~/.dotfiles/gitconfig-personal ~/.gitconfig
# don't create symlink here so this file can be edited for work purposes
ln    ~/.dotfiles/gitconfig-personal ~/work/.gitconfig

# dynamically create machine specific aliases
if ask "Create ~/.machine_aliases.sh? "; then
    cp ./machine_aliases.sh ~/.machine_aliases.sh

    # windows/wsl instance specific aliases
    if ask "Is this a wsl instance?"; then
	echo "adding to .machine_aliases.sh for vscode 'c' and file explorer 'e'..." 
	cat ./wsl.sh >> ~/.machine_aliases.sh

	# vscode extensions
	if ask "Would you like to install vscode extensions? "; then
	    code --install-extension ms-vscode-remote.remote-wsl  # wsl extension
	    code --install-extension ritwickdey.liveserver        # live server
	    code --install-extension yzhang.markdown-all-in-one   # markdown all in one
	    code --install-extension pkief.material-icon-theme    # material icon theme
	fi
    fi

    # arch install
    if ask "Is this an arch machine? "; then
	ln -s ~/.dotfiles/arch/.Xdefaults ~/.Xdefaults
    fi

    if ask "Are you using a window manager? "; then
        # provide user with a selection of window managers 
        options=("i3" "Awesome" "Sike, I'm not using a window manager")
        select opt in "${options[@]}"
        do
            case $opt in
                "i3")
		    cp ~/.config/i3/config ~/.config/i3/config.old
                    ln -s ~/.dotfiles/windowManagers/i3/config ~/.config/i3/config
		    break
                    ;;
                "Awesome")
                    echo "Haven't used awesome yet so nothing to do here"
		    break
                    ;;
                "Sike, I'm not using a window manager")
                    break
                    ;;
                *) echo "invalid option $REPLY";;
            esac
        done

	# are you using polybar
	if ask "Are you using polybar? "; then
            cp ~/.config/polybar/config.ini ~/.config/polybar/config.ini.old
	    ln -s ~/.dotfiles/windowManagers/misc/polybar/config.ini ~/.config/polybar/config.ini
	fi
    fi
fi

# finalize
source ~/.bashrc

