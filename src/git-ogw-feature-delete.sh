#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @line
## @author Philippe Ivaldi <http://www.piprime.fr/>
## @ingroup workflow
## @brief This script delete a feature branch.
## @copyright New BSD
## @version 0.1.0
## @par URL
## https://github.com/OVYA/ogws

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/ovyaGitLib.sh
. $SCRIPT_DIR/_git-util.sh

declare CURRENT_BRANCH=$(oglGetBranch)
declare F_BRANCH="$CURRENT_BRANCH"
declare REBASE_OPTS=""
declare BRANCH_IS_PASSED_AS_PARAM=false
declare ASSUME_YES=false
declare CHECK_STATUS=true

while getopts ":hyx" opt; do
    case ${opt} in
        h)
            echo "Usage : $0 [OPTIONS] [feature_name]"
            echo "Delete the current feature branch or the feature branch passed in argument"
            echo "Options are : "
            echo -e "-h\tDisplay this help message."
            echo -e "-y\tAssume yes."
            echo -e "-x\tDon't check the divergence status of the feature branch."
            exit 0
            ;;
        y)
            ASSUME_YES=true
            ;;
        x)
            CHECK_STATUS=false
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            echo "try $0 -h"
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

[ ! -z $1 ] && {
    F_BRANCH="$1"
    BRANCH_IS_PASSED_AS_PARAM=true

};


isStatusOK() {
    __run "git fetch"

    local M="master"
    local UPS="origin/$1"
    local DS_M=$(oglGetDivergenceStatus "$1" "$M")
    local IS_OK_UPS=$(oglIsBranchUpToDate "$1" "$UPS" && echo true || echo false)
    local IS_OK_MASTER=false

    [[ $DS_M == "$IS_EQUAL"  || $DS_M == "$IS_BEHIND" ]] && IS_OK_MASTER=true

    {
        $IS_OK_MASTER && $IS_OK_UPS
    } || {
        __error "The branch '$1' is not up-to-date."
        $IS_OK_MASTER || __error "'$1' $(oglGetDivergenceStatus $1 $M) regarding $M"
        $IS_OK_UPS || __error "'$1' $(oglGetDivergenceStatus $1 $UPS) regarding $UPS"

        echo "You are invited to manually destroy '$1' if you really want this."

        return 1
    }

    return 0
}

gotoOriginalBranchAndExist() {
    [ "$CURRENT_BRANCH" == "$(oglGetBranch)" ] || {
        __run "git checkout $CURRENT_BRANCH" || __abort
    }

    exit $1
}

deleteBranches() {
    __run "git branch -d $F_BRANCH" || gotoOriginalBranchAndExist 1

    HAS_REMOT=false

    for REMOTE in $(__getRemoteLocalBranches "$F_BRANCH"); do
        __run "git branch -r -d $REMOTE" || __abort
        HAS_REMOT=true
    done

    $HAS_REMOT && {
        $ASSUME_YES || echo -n "Do you also want to delete the branch $F_BRANCH in the remote repository ? "

        if $ASSUME_YES || confirm; then
            __run "git push origin --delete $F_BRANCH"
        else
            echo "Skipped…"
        fi
    }

    return 0
}

###########################
## Execution starts here ##
###########################

__isAFeatureBranchNameLog $F_BRANCH $BRANCH_IS_PASSED_AS_PARAM || __abort
__isBranchExists $F_BRANCH || __abort

$CHECK_STATUS && {
    isStatusOK $F_BRANCH || __abort
} || {
    msg_warning "Not checking if $F_BRANCH is up-to-date !"
}

[ "$CURRENT_BRANCH" == "$F_BRANCH" ] && {
    __run "git checkout master" || __abort
}

deleteBranches || __abort
