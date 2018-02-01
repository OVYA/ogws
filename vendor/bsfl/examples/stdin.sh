#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

declare -r DIR=$(cd "$(dirname "$0")" && pwd)
source $DIR/../lib/bsfl.sh

# --------------------

msg "Use the 'confirm' function to confirm and action :" "$BOLD"
echo -n 'Are you sure ? '
confirm && echo 'Confirm is ok' || echo 'Confirm is ko'

msg "'confirm' assume <yes> when empty response :" "$BOLD"
echo -n 'Are you sure ? '
confirm 'y' && echo 'Confirm is ok' || echo 'Confirm is ko'

msg "'confirm' assume <no> when empty response :" "$BOLD"
echo -n 'Are you sure ? '
confirm 'n' && echo 'Confirm is ok' || echo 'Confirm is ko'

# --------------------

msg "Use the 'read_path' function to read a path with a default value :" "$BOLD"
echo -n 'Give me you prefered path in your file system : '
read_path "/usr/local/" PATH && echo "You entered the path '$PATH'"
