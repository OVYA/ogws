#!/bin/bash

declare -r BASE_DIR=$1
declare FILES=

. $BASE_DIR/bin/commun.rc || exit 1

__unlink() {
    echo -n "Removing file $1 ? "
    # confirm 'y'
     true && {
        rm -r "$1" && {
            msg_success "Rmove $1"
            return 0
        } || {
            msg_error "Rmoving $1"
            return 1
        }
    }
}

[ -e "$INSTALLED_FILES_PATH" ] && FILES=$(cat "$INSTALLED_FILES_PATH")

for file in $FILES; do
    [ -e "$file" ] && {
        __unlink "$file" || exit 1
    }
done

[ -e "$INSTALLED_FILES_PATH" ] && rm "$INSTALLED_FILES_PATH"

exit 0
