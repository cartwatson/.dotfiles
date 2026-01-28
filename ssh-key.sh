#!/usr/bin/env bash
# Author: github.com/cartwatson
# Desc: create ssh keys simply

function error() {
  echo -e "Error: $1!";
  exit 1;
}

function read_if_unset() {
  local var=$1
  local prompt=$2
  if [ -z "$var" ]; then
    read -p "$prompt" var
  fi
  echo "$var"
}

site=""
email=""
type_of_key=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --help | -h)
      echo -e "Simple script to auto create ssh-keys\n"
      echo -e "-t, --type\n\tType of key, work and personal are my deliminators but you can use whatever you'd like"
      echo -e "-e, --email\n\temail for key"
      echo -e "-s, --site\n\tsite for keyname"
      exit 0
      ;;
    --type | -t)
      shift
      type_of_key="$1"
      shift # past argument
      ;;
    --email | -e)
      shift
      email="$1"
      shift # past argument
      ;;
    --site | -s)
      shift
      site="$1"
      shift # past argument
      ;;
    *)
      echo "erm what the sigma is $1, exiting"
      exit 1
      ;;
  esac
done

if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh;
fi

site=$(read_if_unset "$site" "What site is the key for (should be a FQDN (eg github.com))? ")
email=$(read_if_unset "$email" "What is your email? ")
# get input for file_name
if [ -z "$type_of_key" ]; then
  read -p "Is the key for Work or Personal (w/p): " input
  case "$input" in
    w|"work") type_of_key="work" ;;
    p|"personal") type_of_key="personal" ;;
    *) type_of_key=$input
  esac
fi

file_name="$type_of_key@$site"
ssh-keygen -q -t ed25519 -f "$HOME/.ssh/$file_name" -C "$email" -N "$(read -sp "Passphrase for ssh-key (press enter for no passphrase): ")" && echo

if [ -n $SSH_AGENT_PID ]; then
  eval "$(ssh-agent -s)" > /dev/null || error "starting ssh-agent"
fi

# always add file to agent
ssh-add -q ~/.ssh/"$file_name" || error "adding key to ssh-agent"

echo -e "\nSuccessully created new key $file_name and added to ssh-agent"
echo -e "Add the below line to $site as $USER@$HOSTNAME"
cat ~/.ssh/"$file_name".pub

# add to config
read -p "Add $site to ~/.ssh/config (y/n): " input
case "$input" in
  y|"yes")
    # see if it's already been added to ssh/config and bail if it has
    mkdir -p "$HOME/.ssh"
    touch "$HOME/.ssh/config"
    if [ cat "$HOME/.ssh/config" | grep -c "$site" != 0 ]; then
      echo -e "Host $site\n  IdentityFile ~/.ssh/$file_name\n" >> "$HOME/.ssh/config"
      if [ ! $? ]; then
        error "Unable to add key+site combo to ~/.ssh/config";
      fi
    fi
  ;;
  *)
    echo "View your `~/.ssh/config` file and ensure it's correct"
  ;;
esac

echo

