#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

set -e

## @file
## @author Philippe Ivaldi <http://www.piprime.fr/>
## @brief This script create a git bare repository interactively with
## useful options.
## This assume you have the user git-user by default who can execute
## all the git. You can change this user overwriting the environnement variable GIT_USER.
## You can overwrite the default directory (/usr/local/git/) to store
## the repositories setting the environnement variable ROOT_DIR
## commands from a remote git work repository.
## Exemple : GIT_USER=$USER ROOT_DIR=$HOME/git_repos/ git-ogw-create-repos.sh
## @ingroup useful
## @copyright New BSD
## @version 0.0.0
## @par URL
## https://github.com/OVYA/ogws

. /usr/local/bin/vendor/bsfl/lib/bsfl.bash

declare ROOT_DIR=${ROOT_DIR:-'/usr/local/git/'}
declare GIT_USER=${GIT_USER:-'git-user'}
declare ASSUME_YES=false

[[ $ROOT_DIR == */ ]] || ROOT_DIR="${ROOT_DIR}/"

while getopts ":hy" opt; do
    case ${opt} in
        h)
            echo "Usage : [GIT_USER=??? ROOT_DIR=???] $0 [OPTIONS] [repo_name]"
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

[ -z $1 ] && {
    read -e -p "Enter the path of the repository : " -i "$ROOT_DIR" ROOT_DIR
} || ROOT_DIR="${ROOT_DIR}$1"

[[ $ROOT_DIR =~ \.git$ ]] || {
    ROOT_DIR="${ROOT_DIR}.git"
}

$ASSUME_YES || echo "You are about to create a git bare repository in ${ROOT_DIR}"

if $ASSUME_YES || confirm 'y'; then
    git init --bare --shared=group "${ROOT_DIR}"
    cd "${ROOT_DIR}" && git config receive.denyNonFastForwards false || exit 1
    [ $USER == "$GIT_USER" ] || {
        id -u $GIT_USER > /dev/null 2>&1 && chown -R $GIT_USER:$GIT_USER "${ROOT_DIR}"
    }
else
    echo "Process aborted..."
fi

exit 0
