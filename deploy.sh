#!/bin/bash
set -ex -o pipefail

ansible-playbook -i inventory site.yml
