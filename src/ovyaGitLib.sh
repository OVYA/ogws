#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @line
## @author Philippe Ivaldi <http://www.piprime.fr/>
## @author Shawn O. Pearce <spearce@spearce.org>
## @mainpage OVYA Git Bash Script for a Stable Mainline Branching Model
## @details
## @section Workflow_scripts Workflow Scripts
## You'll find *Bash* scripts <a href="group__workflow.html">here</a> that make easy
## to maintain a stable mainline branching model as describe by
## <a href="http://www.bitsnbites.eu/a-stable-mainline-branching-model-for-git/">Marcus Geelnard</a><br>
## The main difference with our branching model compared to Marcus one
## is that we use only one release branch instead of one branch by
## major release.<br>
## Our workflow branching model looks like more to this one : <br>
## @image html stable-environment-branches.svg "© Marcus Geelnard (source here https://goo.gl/NPvQhw )" width=400px
## Further reading : <a href="http://www.bitsnbites.eu/a-tidy-linear-git-history/">A tidy, linear Git history</a>.
## @section useful_scripts Useful Scripts
## You'll find <a href="group__useful.html">here</a> others useful *Git* scripts used in our developers' team.
## @section Libray Libray
## In order to develop the mentioned scripts we have developed a set
## of useful *bash* functions regrouped in the library <a href="ovyaGitLib_8sh.html">ovyaGitLib.sh</a>
## @copyright New BSD
## @version 0.1.0
## @par URL
## https://github.com/OVYA/ogws

# Groups of functions
# --------------------------------------------------------------#

## @defgroup func Useful functions
## @defgroup pfunc Private functions
## @defgroup useful Useful script not directly related to the OVYA Git Workflow
## @defgroup workflow OVYA Git Workflow Script

# Variables
# --------------------------------------------------------------#

## @var IS_NOT_APPLICABLE
## @brief Computation is not applicable.
readonly IS_NOT_APPLICABLE='IS_NOT_APPLICABLE'

## @var INVALID_LOCAL_REF
## @brief The local git reference is not valid.
readonly INVALID_LOCAL_REF='INVALID_LOCAL_REF'

## @var BRANCH_NOT_TRACKING
## @brief The branch does not track an upstream branch or other
## spécified branch.
readonly IS_NOT_TRACKING='IS_NOT_TRACKING'

## @var IS_EQUAL
## @brief The branch is equal to his upstream branch or other
## spécified branch.
readonly IS_EQUAL='IS_EQUAL'

## @var IS_AHEAD
## @brief The branch is ahead of his upstream branch or other
## spécified branch.
readonly IS_AHEAD='IS_AHEAD'

## @var BRANCH_NEED_PUSH
## @brief The branch is behind of his upstream branch or other
## spécified branch.
readonly IS_BEHIND='IS_BEHIND'

## @var HAS_DIVERGED
## @brief The branch has diverged from his upstream branch or other
## spécified branch.
readonly HAS_DIVERGED='HAS_DIVERGED'

## @var HAS_UNSTAGED_FILE
## @brief The branch has unstaged changes
readonly HAS_UNSTAGED_FILE='HAS_UNSTAGED_FILE'

## @var HAS_UNCOMMITTED_CHANGE
## @brief The branch has uncommitted changes
readonly HAS_UNCOMMITTED_CHANGE='HAS_UNCOMMITTED_CHANGE'

## @var IS_CLEAN
## @brief The branch is in a clean status
readonly IS_CLEAN='IS_CLEAN'

## @var IS_EMPTY
## @brief The work tree is empty.
readonly IS_EMPTY='IS_EMPTY'

# Functions
# --------------------------------------------------------------#

## @fn __oglError()
## @ingroup pfunc
## @brief Output errors to stderr
## @param string The message to output
## @retval string echoed in stderr.
__oglError() {
    >&2 echo "$1"
}

## @fn __oglHasUpstreamBranch()
## @ingroup pfunc
## @brief Test if the given branch has on upstream. If not, output an error to stderr.
## @param string The branch to operate on.
## @retval string echoed in stderr if no upstream found.
## @return 0 if upstream found
## @return 1 if upstream NOT found
__oglHasUpstreamBranch() {
    oglHasUpstreamBranch $@ || {
        __oglError "Branch '$1' does not follow an upstream branch"
        return 1
    }

    return 0
}

## @fn oglGetDir()
## @ingroup func
## @copyright Copyright (C) 2006,2007 Shawn O. Pearce <spearce@spearce.org>
## @note Come from git-prompt.sh
## @brief Return the location of .git repo
## @retval string echoed.
oglGetDir() {
    # Note: this function is duplicated in git-completion.bash
    # When updating it, make sure you update the other one to match.
    if [ -z "${1-}" ]; then
        if [ -n "${__git_dir-}" ]; then
            echo "$__git_dir"
        elif [ -n "${GIT_DIR-}" ]; then
            test -d "${GIT_DIR-}" || return 1
            echo "$GIT_DIR"
        elif [ -d .git ]; then
            echo .git
        else
            git rev-parse --git-dir 2>/dev/null
        fi
    elif [ -d "$1/.git" ]; then
        echo "$1/.git"
    else
        echo "$1"
    fi
}

## @fn oglGetBranch()
## @ingroup func
## @copyright Copyright (C) 2006,2007 Shawn O. Pearce <spearce@spearce.org>
## @note Come from git-prompt.sh
## @brief Return the current branch or detached ref
## @retval string echoed.
oglGetBranch() {
    local g="$(oglGetDir)"
    local b=""
    local c=""

    if [ -f "$g/rebase-merge/interactive" ]; then
        b="$(cat "$g/rebase-merge/head-name")"
    elif [ -d "$g/rebase-merge" ]; then
        b="$(cat "$g/rebase-merge/head-name")"
    else
        b="$(git symbolic-ref HEAD 2>/dev/null)" || {
            detached=yes
            b="$(
case "${GIT_PS1_DESCRIBE_STYLE-}" in
(contains)
git describe --contains HEAD ;;
(branch)
git describe --contains --all HEAD ;;
(describe)
git describe HEAD ;;
(* | default)
git describe --tags --exact-match HEAD ;;
esac 2>/dev/null)" ||

                b="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." ||
                b="unknown"
            b="($b)"
        }
    fi

    if [ "true" = "$(git rev-parse --is-inside-git-dir 2>/dev/null)" ]; then
        if [ "true" = "$(git rev-parse --is-bare-repository 2>/dev/null)" ]; then
            c="BARE:"
        else
            b="GIT_DIR!"
        fi
    fi

    echo "$c${b##refs/heads/}"
}

## @fn oglGetStatus()
## @ingroup func
## @brief Return the git work tree status as concatenation by commas of
## the variables HAS_UNCOMMITTED_CHANGE and HAS_UNSTAGED_FILE.
## If the work tree is clean the output is the value of the variable IS_CLEAN.
## If the work tree is empty the output is comma separated of the
## variables IS_CLEAN and IS_EMPTY.
## @param string The optional branch to operate on (current branch if not set).
## @retval 0 if the status can be found
## @retval 1 if the status can not be found (branch does not exist, …)
## @return string Echoed value. See brief.
oglGetStatus() {
    local THE_BRANCH=${1:-$(oglGetBranch)}
    local CURRENT_BRANCH=$(oglGetBranch)
    local RESULT=
    local SEPARATOR=

    oglIsWorkDirEmpty && {
        echo "$IS_CLEAN,$IS_EMPTY"
        return 0
    }
    oglIsBranchExists $THE_BRANCH || {
        __oglError "Branch '$THE_BRANCH' does not exist"
        echo $IS_NOT_APPLICABLE
        return 1
    }

    oglSwitchToBranch $THE_BRANCH || __abort

    # Update the index
    git update-index -q --ignore-submodules --refresh

    # Unstaged changes in the working tree
    if git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' > /dev/null 2>&1
    then
        RESULT="${RESULT}${SEPARATOR}${HAS_UNSTAGED_FILE}"
        SEPARATOR=","
    fi

    # Uncommitted changes in the index
    if ! git diff-index --quiet HEAD --ignore-submodules --
    then
        RESULT="${RESULT}${SEPARATOR}${HAS_UNCOMMITTED_CHANGE}"
        SEPARATOR=","
    fi

    oglSwitchToBranch $CURRENT_BRANCH || __abort

    [ -z $RESULT ] && RESULT="$IS_CLEAN"

    echo $RESULT
}

## @fn oglIsClean()
## @ingroup func
## @brief Test if the work tree is clean. Note that an empty work tree
## is considered clean.
## @param string The optional branch to operate on (current branch if not set).
## @retval 0 if clean
## @retval 1 if not clean
oglIsClean() {
    local STATUS="$(oglGetStatus $@)"

    [[ "$STATUS" == *$IS_CLEAN* ]] && return 0 || return 1
}

## @fn oglHasUnstagedFile()
## @ingroup func
## @brief Test if the work tree has unstaged file(s).
## @param string The optional branch to operate on (current branch if not set).
## @retval 0 if has unstaged file(s)
## @retval 1 if not
oglHasUnstagedFile() {
    local STATUS="$(oglGetStatus $@)"

    [[ "$STATUS" == *$HAS_UNSTAGED_FILE* ]] && return 0 || return 1
}

## @fn oglHasUncommittedChange()
## @ingroup func
## @brief Test if the work tree has uncommitted change(s).
## @param string The optional branch to operate on (current branch if not set).
## @retval 0 if has uncommitted file(s)
## @retval 1 if not
oglHasUncommittedChange() {
    local STATUS="$(oglGetStatus $@)"

    [[ "$STATUS" == *$HAS_UNCOMMITTED_CHANGE* ]] && return 0 || return 1
}

## @fn oglSwitchToBranch()
## @ingroup func
## @brief Switch to the given branch if it's not the current branch
## @param string The branch to go.
## @retval 0 if the switch is done
## @retval 1 if the switch is failed
oglSwitchToBranch() {
    local CURRENT_BRANCH=$(oglGetBranch)
    local THE_BRANCH=$1

    [ "$CURRENT_BRANCH" == "$THE_BRANCH" ] || {
        git checkout -q "$THE_BRANCH" && return 0 || return 1
    }

    return 0
}

oglIsWorkDirEmpty() {
    git log -- HEAD^..HEAD > /dev/null 2>&1 && return 1 || return 0
}

## @fn oglIsBranchUpToDate()
## @ingroup func
## @brief Test if a branch is up-to-date regarding the upstream
## branch or the given branch. The branch "is up-to-date" when the
## branch is equal to the given tracking brach or if there is no tracking branch.
## @param string The branch to operate on. If not set the current.
## @param string The branch to operate on. If not set the upstream branch.
## @retval 0 if up-to-date
## @retval 1 if NOT up-to-date
oglIsBranchUpToDate() {
    local STATUS="$(oglGetDivergenceStatus $@)"

    # echo "@@@@ $STATUS @@@"

    if [ "$STATUS" ==  "$IS_EQUAL" ] || [ "$STATUS" == "$IS_NOT_TRACKING" ] || [ "$STATUS" == "$IS_AHEAD" ];
    then
        return 0
    elif [ "$STATUS" ==  "$IS_BEHIND" ] || [ "$STATUS" == "$HAS_DIVERGED" ];
    then
        return 1
    else
        __oglError "Unrecognized status : '$STATUS'"
        return 1
    fi
}

## @fn oglIsBranchNeedUpdate()
## @ingroup func
## @brief Test if a branch need to be update regarding the upstream
## branch or the given branch. The branch "need to be update" when the
## branch is behind, has diverged.
## @param string The branch to operate on. If not set the current.
## @param string The branch to operate on. If not set the upstream branch.
## @retval 0 if need update
## @retval 1 if NOT need update
oglIsBranchNeedUpdate() {
    local STATUS="$(oglGetDivergenceStatus $@)"

    # echo "@@@@ $STATUS @@@"

    if [ "$STATUS" ==  "$IS_BEHIND" ] || [ "$STATUS" == "$HAS_DIVERGED" ];
    then
        return 0
    elif [ "$STATUS" ==  "$IS_EQUAL" ] || [ "$STATUS" == "$IS_AHEAD" ] || [ "$STATUS" == "$IS_NOT_TRACKING" ];
    then
        return 1
    else
        __oglError "Unrecognized status : '$STATUS'"
        return 1
    fi
}

## @fn oglGetDivergenceStatus()
## @ingroup func
## @brief Return the branches divergence status.
## @param string The branch A to operate on. If not set, use the current
## branch.
## @param string The branch B to operate on. If not set :
## ⋅ use the upstream branch tracked by A is configured ;
## ⋅ else use the remote branch of origin/A if exists ;
## ⋅ else return the value of $IS_NOT_TRACKING.
## @retval string One of the value of the global variable IS_EQUAL,
## IS_AHEAD, IS_BEHIND, HAS_DIVERGED, INVALID_LOCAL_REF,
## IS_NOT_TRACKING, IS_NOT_APPLICABLE.
oglGetDivergenceStatus() {
    local THE_BRANCH=${1:-$(oglGetBranch)}
    local UPSTREAM=${2:-'@{u}'}
    local UPS_IS_VALID_REF=
    local THE_BRANCH_IS_VALID_REF=
    local MUST_UPDATE_REMOTE=false

    oglIsBranchExists $THE_BRANCH || {
        __oglError "Branch '$THE_BRANCH' does not exist"
        echo $IS_NOT_APPLICABLE
        return 1
    }

    [ $UPSTREAM == '@{u}' ] && {
        __oglHasUpstreamBranch $THE_BRANCH && {
            UPSTREAM="${THE_BRANCH}@{u}"
        } || {
            oglIsValidRef "origin/$THE_BRANCH" && {
                UPSTREAM="origin/$THE_BRANCH"
            } || {
                echo $IS_NOT_TRACKING
                return 1
            }
        }
    }

    git remote update > /dev/null 2>&1

    oglIsValidRef $UPSTREAM && UPS_IS_VALID_REF=true || UPS_IS_VALID_REF=false
    oglIsValidRef $THE_BRANCH && THE_BRANCH_IS_VALID_REF=true || THE_BRANCH_IS_VALID_REF=false

    {
        $UPS_IS_VALID_REF && $THE_BRANCH_IS_VALID_REF
    } || {
        echo "$INVALID_LOCAL_REF"

        $UPS_IS_VALID_REF || __oglError "$INVALID_LOCAL_REF $UPSTREAM"
        $THE_BRANCH_IS_VALID_REF || __oglError "$INVALID_LOCAL_REF $THE_BRANCH"

        return 1
    }

    local CMD="git rev-list --count --left-right ${UPSTREAM}...${THE_BRANCH}"
    local COUNT="$($CMD  2> /dev/null)"

    case "$COUNT" in
        "") # Failed
            echo $IS_NOT_APPLICABLE
            return 1

            ;;
        "0	0") # equal to upstream
            echo $IS_EQUAL

            ;;
        "0	"*) # ahead of upstream
            echo $IS_AHEAD

            ;;
        *"	0") # behind upstream
            echo $IS_BEHIND

            ;;
        *) # diverged from upstream
            echo $HAS_DIVERGED
            ;;
    esac
}

## @fn oglHasUpstreamBranch()
## @ingroup func
## @brief Tests if the upstream branch is configured.
## @param string Branch to operate on. Current branch if not set.
## @retval 0 if upstream branch is configured
## @retval 1 if upstream branch is NOT configured
oglHasUpstreamBranch() {
    local THE_BRANCH=${1:-$(oglGetBranch)}
    git rev-parse --abbrev-ref --symbolic-full-name $THE_BRANCH@{u} > /dev/null 2>&1 && return 0 || return 1
}

## @fn oglGetUpstreamBranch()
## @ingroup func
## @brief Return current upstream branch if any, empty if no upstream
## configured for the branch
## @param string Branch to operate on. Current branch if not set.
## @retval 0 if upstream branch is configured
## @retval 1 if upstream branch is NOT configured
## @return string
oglGetUpstreamBranch() {
    local THE_BRANCH=${1:-$(oglGetBranch)}

    __oglHasUpstreamBranch $THE_BRANCH || {
        echo ''
        return 0
    }

    git rev-parse --abbrev-ref --symbolic-full-name $THE_BRANCH@{u} 2> /dev/null
}

## @fn oglHasRemoteBranch()
## @ingroup func
## @brief Tests if the branch has a remote branch.
## @param string Branch to operate on. Current branch if not set.
## @retval 0 if upstream branch is configured
## @retval 1 if upstream branch is NOT configured
oglHasRemoteBranch() {
    local THE_BRANCH=${1:-$(oglGetBranch)}

    git branch -a | grep -qE "^..remotes/[^/]+/$THE_BRANCH\$" && return 0 || return 1
}

## @fn oglGetRemoteBranches()
## @ingroup func
## @brief Return the remote branches if any, empty if no remote branches found.
## @param string Branch to operate on. Current branch if not set.
## @retval 0 if remote branch found.
## @retval 1 if remote branch not found.
## @return string
oglGetRemoteBranches() {
    local THE_BRANCH=${1:-$(oglGetBranch)}

    oglHasRemoteBranch $THE_BRANCH || {
        echo ''
        return 0
    }

    git branch -a | grep -E "^..remotes/[^/]+/$THE_BRANCH\$" | sed -E 's!^..remotes/!!g'
}

## @fn oglIsBranchExists()
## @ingroup func
## @brief Test if the branch exists.
## @param string Branch to operate on.
## @retval 0 if the branch exists
## @retval 1 if the branch does not exist
oglIsBranchExists() {
    git branch -a | grep -qE "^..$1\$|^..remotes/$1\$" && return 0 || {
            # Test because of empty git work dir
            [ "$1" == $(oglGetBranch) ] && return 0 || return 1
        }
}

## @fn oglIsValidRef
## @ingroup func
## @brief Test if the given reference is valid in the local repository.
## The reference can be a commit hash, HEAD, @{u}, a branch name, a
## tag, etc.
## @param string The ref to test.
## @retval 0 if the ref exists
## @retval 1 if the ref does not exist
oglIsValidRef() {
    local ref=$1

    (
        set +e
        git rev-parse $ref > /dev/null 2>&1 && return 0 || return 1
    )
}
