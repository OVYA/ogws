#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @line
## @author Philippe Ivaldi <http://www.piprime.fr/>
## @ingroup workflow
## @brief This script rebase a feature branch interactively.
## @param [options]. More help with the options -h
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

# Parse options to the `pip` command
while getopts ":hi" opt; do
    case ${opt} in
        h )
            echo "Usage : $0 [OPTIONS] [BRANCH]"
            echo "Options are : "
            echo "\t-h\t\tDisplay this help message."
            echo "\t-i\t\tRebase interactively.."
            exit 0
            ;;
        i )
            REBASE_OPTS="-i "
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

[ ! -z $1 ] && {
    F_BRANCH="$1"
    BRANCH_IS_PASSED_AS_PARAM=true
};

gotoFeatureBranch() {
    [ "$CURRENT_BRANCH" == "$F_BRANCH" ] || {
        __run "git checkout ${F_BRANCH}" || __abort
    }
}

gotoOriginalBranch() {
    [ "$CURRENT_BRANCH" == "$F_BRANCH" ] || {
        __run "git checkout ${CURRENT_BRANCH}" || __abort
    }
}

ensureUptodateFromRemote() {
    local REMOTE="origin/${F_BRANCH}"
    local DIV_STATUS=

    oglIsValidRef $REMOTE && {
        DIV_STATUS=$(oglGetDivergenceStatus "$F_BRANCH" "$REMOTE")

        [[ $DIV_STATUS == $IS_EQUAL ]] || {
            gotoFeatureBranch
            __run "git rebase $REMOTE" || __abort
        }
    }
}

###########################
## Execution starts here ##
###########################

__isAFeatureBranchNameLog $F_BRANCH $BRANCH_IS_PASSED_AS_PARAM || __abort
__isBranchExists $F_BRANCH || __abort

__run "git ogw-master-update.sh" || __abort
ensureUptodateFromRemote
gotoFeatureBranch || __abort
__run "git rebase ${REBASE_OPTS}master" || __abort
# __run "git push --force-with-lease origin $F_BRANCH" || __abort
gotoOriginalBranch || __abort
