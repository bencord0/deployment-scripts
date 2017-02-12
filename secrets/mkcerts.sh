#!/bin/bash
CERTROOT="$(dirname "$(readlink -fn "${BASH_SOURCE[0]}")")"

ensure_dir() {
  mkdir -p "${CERTROOT}/${1}"
}

ensure_key() {
  if [[ ! -e "${CERTROOT}/secrets/${1}" ]]; then
    certtool --generate-privkey > "${CERTROOT}/secrets/${1}"
  fi
}

ensure_ca_cert() {
  # $1: certificate path
  # $2: secret key path
  # $3: template path
  CERT_PATH="${CERTROOT}/certs/${1}"
  KEY_PATH="${CERTROOT}/secrets/${2}"
  TEMPLATE_PATH="${CERTROOT}/templates/${3}"

  if [[ ! -e "${CERT_PATH}" ]]; then
    certtool --generate-self-signed \
      --load-privkey "${KEY_PATH}" \
      --template "${TEMPLATE_PATH}" \
      --outfile "${CERT_PATH}"
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

  if [[ ! -e "${CERT_PATH}" ]]; then
    certtool --generate-certificate \
      --load-privkey "${KEY_PATH}" \
      --load-ca-privkey "${CA_KEY_PATH}" \
      --load-ca-certificate "${CA_CERT_PATH}" \
      --template "${TEMPLATE_PATH}" \
      --outfile "${CERT_PATH}"
  fi
}

ensure_dir secrets
ensure_dir certs

ensure_key ca.key
ensure_key server.key
ensure_key client.key

ensure_ca_cert ca.pem ca.key ca.template
ensure_cert server.pem server.key server.template ca.pem ca.key
ensure_cert client.pem client.key client.template ca.pem ca.key
