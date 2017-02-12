#!/bin/bash
set -e -o pipefail

if [[ -z "${1}" ]]; then
  echo "No deployment specified"
  exit 1
fi

_deployment="${1}"

_SECRETS="
  vars/secrets.yml
  vars/environment.sh
"

decrypt_secrets() {
  for sec in $_SECRETS; do
    gpg -d "${sec}".gpg > "${sec}"
  done
}

destroy_secrets() {
  for sec in $_SECRETS; do
    rm -fv "${sec}"
  done
}

trap destroy_secrets EXIT
decrypt_secrets

source vars/environment.sh
ansible-playbook --inventory-file inventory --diff "${_deployment}.yml"
