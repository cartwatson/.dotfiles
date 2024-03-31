# NOTES:
<# 1. install scoop
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
#>
#  2. install git with scoop
#  3. install helix with scoop
#  4. run this script
<# add the following to ssh config; TODO: replace JWatson
Host github.com
  IdentityFile C:\Users\JWatson\.ssh\id_ed25519-github
#>

cp ~\.dotfiles\helix\config.toml ~\AppData\Roaming\helix\config.toml
cp ~\.dotfiles\gitconfig-personal ~\gitconfig
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519-github
