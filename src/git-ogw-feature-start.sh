#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @line
## @author Philippe Ivaldi <http://www.piprime.fr/>
## @ingroup workflow
## @brief This script create a feature branch interactively.
## @copyright New BSD
## @version 0.1.0
## @par URL
## https://github.com/OVYA/ogws

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/ovyaGitLib.sh
. $SCRIPT_DIR/_git-util.sh

CURRENT_BRANCH=$(oglGetBranch)
declare ASSUME_YES=false
declare F_BRANCH=
declare BRANCH_IS_PASSED_AS_PARAM=false

while getopts ":hy" opt; do
    case ${opt} in
        h)
            echo "Usage : $0 [OPTIONS] [feature_name]"
            echo "Options are : "
            echo -e "-h Display this help message."
            echo -e "-y Assume yes."
            exit 0
            ;;
        y)
            ASSUME_YES=true
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            echo "try $0 -h"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

master_update() {
    $ASSUME_YES || echo -n 'Do you want to update the master branch before (recomanded) ? '
    if $ASSUME_YES || confirm 'y'; then
        __run "git ogw-master-update.sh" || __abort
    fi
}

master_update

[ -z $1 ] && {
    F_BRANCH=$(__readFeatureBranchName)
} || {
    F_BRANCH="$1"
    BRANCH_IS_PASSED_AS_PARAM=true
}

__isAFeatureBranchNameLog $F_BRANCH $BRANCH_IS_PASSED_AS_PARAM || __abort

CHECKOUT_CMD="git checkout -b $F_BRANCH"

if oglHasRemoteBranch master; then
    CHECKOUT_CMD="${CHECKOUT_CMD} $(oglGetRemoteBranches master)"
else
    CHECKOUT_CMD="${CHECKOUT_CMD} master"
fi

__run "$CHECKOUT_CMD"
