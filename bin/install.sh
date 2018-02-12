#!/bin/bash

set -e

declare -r BASE_DIR=$1
. $BASE_DIR/bin/commun.rc || exit 1

$BASE_DIR/bin/uninstall.sh $1 || exit 1

[ -e "$DEST_DIR" ] || {
    mkdir -p "$DEST_DIR"
}

__link() {
    ln -s $1 $2 && {
        msg_success "$1 linked to $2"
        echo $2 >> "$INSTALLED_FILES_PATH"
    } || {
        msg_error "$1 linking to $2"
    }
}

find ${SRC_DIR} -type f -print0 | while IFS= read -r -d $'\0' FILE; do
    DEST_FILE="${DEST_DIR}/$(basename $FILE)"
    [ ! -e $DEST_FILE ] && __link "$FILE" "$DEST_FILE"
done

declare LSLF_SRC_DIR="${BASE_DIR}/vendor/bsfl"
declare VENDOR_DEST_DIR="$DEST_DIR/vendor"

[ ! -e "$VENDOR_DEST_DIR" ] && {
    mkdir $VENDOR_DEST_DIR && msg_success "'$VENDOR_DEST_DIR' created" || msg_error "Creating '$VENDOR_DEST_DIR'"
}

[ ! -e "${VENDOR_DEST_DIR}/bsfl" ] && __link "${LSLF_SRC_DIR}" "${VENDOR_DEST_DIR}/"

if [[ ! ":$PATH:" == *":$HOME/bin:"* ]]; then
    msg_warning "YOU must add the directory '$DEST_DIR' is in your path !"
fi
