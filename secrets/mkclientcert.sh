#!/bin/bash
CERTROOT="$(dirname "$(readlink -fn "${BASH_SOURCE[0]}")")"

ensure_key() {
  if [[ ! -e "${CERTROOT}/secrets/${1}" ]]; then
    certtool --generate-privkey > "${CERTROOT}/secrets/${1}"
  fi
}

ensure_cert() {
  # $1: certificate path
  # $2: secret key path
  # $3: template path
  # $4: ca certificate path
  # $5: ca key path

  CERT_PATH="${CERTROOT}/certs/${1}"
  KEY_PATH="${CERTROOT}/secrets/${2}"
  TEMPLATE_PATH="${CERTROOT}/templates/${3}"
  CA_CERT_PATH="${CERTROOT}/certs/${4}"
  CA_KEY_PATH="${CERTROOT}/secrets/${5}"

  certtool --generate-certificate \
      --load-privkey "${KEY_PATH}" \
      --load-ca-privkey "${CA_KEY_PATH}" \
      --load-ca-certificate "${CA_CERT_PATH}" \
      --template "${TEMPLATE_PATH}" \
      --outfile "${CERT_PATH}"
}

ensure_template() {

  # DN examples
  # CN=$username
  # CN=$username,O=$group1
  # CN=$username,O=$group1,O=$group2

  USERNAME="${1}"
  local DN="CN=${USERNAME}"
  shift

  while [[ -n "${1}" ]]; do
    DN="${DN},O=${1}"
    shift
  done

  echo "Creating certificate for ${DN}"
  m4 -D DN="${DN}" \
    < "${CERTROOT}/templates/client.template.in" \
    > "${CERTROOT}/templates/${USERNAME}.template"
}

if [[ -z "${1}" ]]; then
  echo "usage: ${0} <username> [group]..."
  exit 1
fi

ensure_key "${1}.key"
ensure_template $@
ensure_cert "${1}.pem" "${1}.key" "${1}.template" ca.pem ca.key
