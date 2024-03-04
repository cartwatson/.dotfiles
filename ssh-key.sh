#!/usr/bin/env bash
# Author: github.com/cartwatson
# Desc: create ssh keys simply

function error() {
  echo -e "Error: $1!";
  exit 1;
}

if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh;
fi

read -p "What site is the key for? " site
read -p "What is your email? " email
read -p "If you would like a passphrase, enter it: " passphrase

ssh-keygen -q -t ed25519 -f ~/.ssh/"$site" -C "$email" -N "$passphrase" || error "generating key"

if [ -n $SSH_AGENT_PID ]; then
  eval "$(ssh-agent -s)" > /dev/null || error "starting ssh-agent"
  ssh-add -q ~/.ssh/"$site" || error "adding key to ssh-agent"
fi

echo -e "\nSuccessully created new key and added to ssh-agent"
echo -e "Add the below to $site.com\n"
cat ~/.ssh/"$site".pub

