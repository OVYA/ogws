#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @line
## @author Philippe Ivaldi <http://www.piprime.fr/>
## @ingroup workflow
## @brief This script push properly a feature branch.
## @copyright New BSD
## @version 0.1.0
## @par URL
## https://github.com/OVYA/ogws

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/ovyaGitLib.sh
. $SCRIPT_DIR/_git-util.sh

declare CURRENT_BRANCH=$(oglGetBranch)
declare F_BRANCH="$CURRENT_BRANCH"
declare BRANCH_IS_PASSED_AS_PARAM=false

while getopts ":h" opt; do
    case ${opt} in
        h)
            echo "Usage : $0 [OPTIONS] [feature_name]"
            echo "Options are : "
            echo -e "-h\tDisplay this help message."
            exit 0
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            echo "try $0 -h"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

[ -z $1 ] || {
    F_BRANCH="$1"
    BRANCH_IS_PASSED_AS_PARAM=true
}

__isAFeatureBranchNameLog $F_BRANCH $BRANCH_IS_PASSED_AS_PARAM || __abort
__isBranchExists $F_BRANCH || __abort

__run "git push --force-with-lease origin $F_BRANCH" || __abort
