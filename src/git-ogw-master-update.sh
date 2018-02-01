#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @line
## @ingroup workflow
## @author Philippe Ivaldi <http://www.piprime.fr/>
## @brief This script rebase the master branch from the upstream
## branch if needed from wathever current branch you are.
## @copyright New BSD
## @version 0.0.0
## @par URL
## https://github.com/OVYA/ogws

SCRIPT_DIR=$(dirname $0)

. $SCRIPT_DIR/ovyaGitLib.sh
. $SCRIPT_DIR/_git-util.sh

declare CURRENT_BRANCH="$(oglGetBranch)"
declare MUST_GO_TO_ORIGINAL_BRANCH=false
declare STATUS=

oglHasRemoteBranch master && {
    __run "git fetch" || __abort
}

STATUS=$(oglGetDivergenceStatus master)

[[ $STATUS == $IS_BEHIND || $STATUS == $HAS_DIVERGED ]] && {
    [ $CURRENT_BRANCH != 'master' ] && {
        __run "git checkout master" && MUST_GO_TO_ORIGINAL_BRANCH=true || __abort
    }

    __run "git rebase" || __abort
}

$MUST_GO_TO_ORIGINAL_BRANCH && {
    __run "git checkout $CURRENT_BRANCH"
}

exit 0
