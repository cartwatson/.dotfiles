#!/usr/bin/env bash
# Author: github.com/cartwatson
# Desc: create ssh keys simply

function error() {
  echo -e "Error: $1!";
  exit 1;
}

function read_if_unset() {
  if [ -z "$1" ]; then
    read -p "$2" $1
  fi
  echo "$1"
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
      POSITIONAL_ARGS+=("$1") # save positional arg
      echo "erm what the sigma is $1, exiting"
      exit 1
      ;;
  esac
done

if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh;
fi

site=$(read_if_unset "$site" "What site is the key for? ")
email=$(read_if_unset "$email" "What is your email? ")
# get input for file_name
if [ -z "$type_of_key" ]; then
  input=$(read_if_unset "$type_of_key" "Is the key for Work or Personal (w/p): ")
  case "$input" in
    w|"work") type_of_key="work" ;;
    p|"personal"|"") type_of_key="personal" ;;
    *) type_of_key=$input
  esac
fi
# NOTE: not a CLI option for security
read -p "Passphrase for ssh-key, if not desired press enter: " passphrase


file_name="$site@$type_of_key"
ssh-keygen -q -t ed25519 -f ~/.ssh/"$file_name" -C "$email" -N "$passphrase" || error "generating key"

if [ -n $SSH_AGENT_PID ]; then
  eval "$(ssh-agent -s)" > /dev/null || error "starting ssh-agent"
fi

# always add file to agent
ssh-add -q ~/.ssh/"$file_name" || error "adding key to ssh-agent"

echo -e "\nSuccessully created new key $file_name and added to ssh-agent"
echo -e "Add the below to $site as user@hostname\n"
cat ~/.ssh/"$file_name".pub
echo

