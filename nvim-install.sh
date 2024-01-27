###############################################################################
#
# NeoVim Install Script 
# - Needs to be run as sudo, eg `sudo ./nvim-install.sh`
# - Always grabs most recent version
#
###############################################################################

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version

# Optional: exposing nvim globally.
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
rm nvim.appimage

