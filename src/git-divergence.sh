#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @line
## @author Gary Bernhardt <https://github.com/garybernhardt/dotfiles/blob/master/bin/git-divergence>
## @ingroup useful
## @brief Gives a list of incoming commits, on branchB and not
## branchB, and outgoing commits, on branchB and not branchA.
## @param branchA. If not set, use the current branch for branchA and
## the tracking branch for branchB.
## @param branchB. If not set, use the current branch for branchA and the first param is used for branchB
## @version 0.1.0
## @par URL
## https://github.com/OVYA/ogws

set -e

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/ovyaGitLib.sh
# . $SCRIPT_DIR/_git-util.sh

(
    showRev() {
        local LOCAL=
        local REMOTE=
        local rev=$1

        git log -1 $rev --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
        echo
        git diff $rev^..$rev | diffstat -C
        echo
    }

    if [[ $# == 2 ]]; then
        LOCAL=$1
        REMOTE=$2
    elif [[ $# == 1 ]]; then
        LOCAL=$(oglGetBranch)
        REMOTE=$1
    else
        LOCAL=$(oglGetBranch)
        REMOTE=origin/$LOCAL
    fi

    oglIsValidRef $LOCAL || {
        echo "Bad ref : $LOCAL" >&2
        exit 1
    }

    oglIsValidRef $REMOTE || {
        echo "Bad ref : $REMOTE" >&2
        exit 1
    }

    echo "# Changes from ${LOCAL} to ${REMOTE}"
    echo

    echo '## Incoming'
    echo

    for rev in $(git rev-list $LOCAL..$REMOTE); do
        showRev $rev
    done

    echo
    echo '## Outgoing'
    echo

    for rev in $(git rev-list $REMOTE..$LOCAL); do
        showRev $rev
    done
) | less -r
