#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @line
## @author Philippe Ivaldi <http://www.piprime.fr/>
## @ingroup workflow
## @brief This script close a feature branch interactively.
## If the feature branch is not deleted, the feature branch will be pushed.
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
declare FORCE_DELETE=false
declare BRANCH_IS_PASSED_AS_PARAM=false
declare ASSUME_YES=false

while getopts ":hyd" opt; do
    case ${opt} in
        h)
            echo "Usage : $0 [OPTIONS] [feature_name]"
            echo "Options are : "
            echo -e "-h\tDisplay this help message."
            echo -e "-y\tAssume yes. You may use the option -d to also delete the branch."
            echo -e "-d\tDelete the feature when -y is passed. Without the"
            echo -e "\toption -y, always ask for deleting the feature."
            exit 0
            ;;
        y)
            ASSUME_YES=true
            ;;
        d)
            FORCE_DELETE=true
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            echo "try $0 -h"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

[ ! -z $1 ] && {
    F_BRANCH="$1"
    BRANCH_IS_PASSED_AS_PARAM=true
};

rebaseBranchOnMaster() {
    local OPTS='-i '
    local F_BRANCH="$1"

    $ASSUME_YES || {
        echo "You are about to make the branch '$F_BRANCH' on top of the master branch."
        echo -n "Do you realy want this ? "
    }

    if $ASSUME_YES || confirm 'y'; then
        $ASSUME_YES && OPTS='' || {
                echo
                $ASSUME_YES || \
                    echo "Please, before sharing your commits make sure they make sense by interactively rebasing them…"
            }

        __run "git-ogw-feature-update.sh ${OPTS}${F_BRANCH}" || __abort
    else
        echo 'Process aborted…'
        __abort
    fi

    return 0
}

mergeToMaster() {
    local TICKET=$(__extractTicketNumFromFeatureBranchName $F_BRANCH)
    local MSG="Fix #${TICKET}"
    local MSG_COMPLEMENT=
    local MERGE_OPTIONS="--no-ff -m '$MSG'"

    $ASSUME_YES || {
        MERGE_OPTIONS="$MERGE_OPTIONS --edit"
    }

    [[ $(oglGetBranch) == 'master' ]] || {
        __run "git checkout master" || __abort
    }

    __run "git merge $MERGE_OPTIONS $F_BRANCH" || __abort

    return 0
}


deleteBranches() {
    local OPTS="-x" ## Because of rebasing, no need to check again divergence status
    local F_BRANCH="$1"

    $ASSUME_YES && OPTS="${OPTS} -y"

    $ASSUME_YES || {
        echo
        echo -n "Do you whant to delete the branch '${F_BRANCH}' ? "
    }

    if $ASSUME_YES || confirm; then
        __run "git ogw-feature-delete.sh ${OPTS} ${F_BRANCH}"
    else
        return 1
    fi

    return 0
}

###########################
## Execution starts here ##
###########################

__isAFeatureBranchNameLog $F_BRANCH $BRANCH_IS_PASSED_AS_PARAM || __abort
__isBranchExists $F_BRANCH || __abort
__isBranchClean $F_BRANCH || __abort
__isBranchAllreadyMergedToMaster $F_BRANCH && __abort
rebaseBranchOnMaster $F_BRANCH || __abort
mergeToMaster || __abort
__run "git push --force-with-lease origin master" || __abort

{
    {
        $FORCE_DELETE || ! $ASSUME_YES
    }  && {
        deleteBranches $F_BRANCH
    }
} || {
    __run "git-ogw-feature-push.sh $F_BRANCH" || __abort
}
