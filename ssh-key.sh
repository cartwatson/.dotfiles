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

# get input for file_name
read -p "Is the key for Work or Personal (w/p): " input
case "$input" in
  w|"work") type_of_key="work" ;;
  p|"personal"|"") type_of_key="personal" ;;
  *) type_of_key=$input
esac

file_name="$site@$type_of_key"
ssh-keygen -q -t ed25519 -f ~/.ssh/"$file_name" -C "$email" -N "$passphrase" || error "generating key"

if [ -n $SSH_AGENT_PID ]; then
  eval "$(ssh-agent -s)" > /dev/null || error "starting ssh-agent"
fi

# always add file to agent
ssh-add -q ~/.ssh/"$file_name" || error "adding key to ssh-agent"

echo -e "\nSuccessully created new key $file_name and added to ssh-agent"
echo -e "Add the below to $site.com as user@hostname\n"
cat ~/.ssh/"$file_name".pub
echo

