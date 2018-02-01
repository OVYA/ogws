#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

declare -r DIR=$(cd "$(dirname "$0")" && pwd)
source $DIR/../lib/bsfl.sh

# --------------------

is_root && echo 'You are root' || echo 'You are not root'

# --------------------

declare USER='qhqs9sck3sdxm9n'
is_user_exists "$USER" && echo "The user '$USER' exists" || echo "The user '$USER' does not exist"

USER=$(whoami)
is_user_exists "$USER" && echo "The user '$USER' exists" || echo "The user '$USER' does not exist"
