#!/bin/bash
set -ex -o pipefail

_SECRETS="
  vars/secrets.yml
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

ansible-playbook -i inventory site.yml
