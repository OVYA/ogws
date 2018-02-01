#!/usr/bin/env BASH

trap __finish EXIT


[ -z $TEST_MODE ] && TEST_MODE=false

. /usr/local/bin/vendor/bsfl/lib/bsfl.bash

declare __TEST_MODE_WARN_PASSED=false

[ -z $OGW_ECHO_OFFSET_NUM ] && OGW_ECHO_OFFSET_NUM=0

function __finish {
    [ "$OGW_ECHO_OFFSET_NUM" -eq 0 ] || OGW_ECHO_OFFSET_NUM=$((OGW_ECHO_OFFSET_NUM-1))
}

__run() {
    $TEST_MODE && {
        $__TEST_MODE_WARN_PASSED || {
            msg_warning "Test mode is enabled, no command will be executed…"
            __TEST_MODE_WARN_PASSED=true
        }

        echo "-> $1"
    } || {
        [ "$OGW_ECHO_OFFSET_NUM" -eq 0 ] || OFFSET=$(printf "\t%.0s" $(seq $OGW_ECHO_OFFSET_NUM))
        echo "${OFFSET}-> $1"

        OGW_ECHO_OFFSET_NUM=$((OGW_ECHO_OFFSET_NUM+1)) eval "$1" && msg_success "${OFFSET}$($GREEN)<-$($DEFAULT_CLR) $1" || {
                msg_error "${OFFSET}$($RED)<-$($DEFAULT_CLR) $1"
                return 1
            }
    }
}

__getFeatureBranchNameRegExp() {
    echo '(^[a-zA-Z][a-zA-Z_]*-[0-9]+$)|(^[0-9]+$)'
}

__isAFeatureBranchName() {
    REGEXP="$(__getFeatureBranchNameRegExp)"
    echo "$1" | grep -qE "$REGEXP"

    return $?
}

__getRemoteLocalBranches() {
    git branch -ar | grep -E "^ +[^/]+/$1\$" | sed 's/ //g'
}

__echoBadFeatureBranchName() {
    echo "$($RED)'$1' does not match the regexp $(__getFeatureBranchNameRegExp)$($DEFAULT_CLR)" >&2
}

__readFeatureBranchName() {
    BRANCH_MUST_EXIST="false"
    REGEXP="$(__getFeatureBranchNameRegExp)"

    [ "$1" == "-e" ] && {
        BRANCH_MUST_EXIST="true"
    }

    while : ; do
        read -p "Enter the feature branch name (pattern is ${REGEXP}) : " FEATURE_NAME

        __isAFeatureBranchName "$FEATURE_NAME" && {
            $BRANCH_MUST_EXIST && {
                oglIsBranchExists $FEATURE_NAME && break || {
                        __error "The branch '${FEATURE_NAME}' does not exist"
                    }
            } || break
        } || {
            __echoBadFeatureBranchName ${FEATURE_NAME}
            echo -e "Try again my friend\n" >&2
        }
    done

    echo "${FEATURE_NAME}"
}

__error() {
    msg_error "$($RED)$1$($DEFAULT_CLR)"
}

__abortBadStatus() {
    local CURRENT_BRANCH=$1
    local F_BRANCH=$2

    [ "$CURRENT_BRANCH" == "$F_BRANCH" ] || {
        git checkout -q  $F_BRANCH
    }

    git status
    local STATUS=$(oglGetStatus)

    [ "$CURRENT_BRANCH" == "$F_BRANCH" ] || {
        git checkout -q  $CURRENT_BRANCH
    }

    echo
    __error "The branch $F_BRANCH is not ready, his status is '$STATUS'."

    __abort
}


__extractTicketNumFromFeatureBranchName() {
    echo $1 | grep -E $(__getFeatureBranchNameRegExp) | sed -E "s;$(__getFeatureBranchNameRegExp);\\1\\2;g"
}


__isAFeatureBranchNameLog() {
    local F_BRANCH=$1
    local BRANCH_IS_PASSED_AS_PARAM=$2

    __isAFeatureBranchName "$F_BRANCH" || {
        __echoBadFeatureBranchName "$F_BRANCH"

        $BRANCH_IS_PASSED_AS_PARAM && {
            echo 'You have passed a wrong feature branch name'
        } || {
            echo 'You can pass a feature branch name as parameter'
        }

        return 1
    }

    return 0
}

__isBranchExists() {
    oglIsBranchExists "$1" || {
        __error "The branch '$1' does not exist !"

        return 1
    }

    return 0
}

__isBranchClean() {
    $(oglIsClean "$1") || {
        __abortBadStatus "$CURRENT_BRANCH" "$1"

        return 1
    }

    return 0
}

__isBranchAllreadyMergedToMaster() {
    git branch --merged master | grep $1 && {
        __error "The branch '$1' have already been merged into master."
        __error "You have started to manage this feature branch manually so continue manually."

        return 0
    }

    return 1
}

__abort() {
    __error 'Process aborted.'
    exit 1
}
