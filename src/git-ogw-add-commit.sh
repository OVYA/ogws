#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

## @file
## @line
## @author Philippe Ivaldi <http://www.piprime.fr/>
## @ingroup useful
## @brief This script create a fancy numbered test commit adding one file
## @copyright New BSD
## @version 0.0.0
## @par URL
## https://github.com/OVYA/ogws

SCRIPT_DIR=$(dirname $0)

. $SCRIPT_DIR/ovyaGitLib.sh

BRANCH="$(oglGetBranch)"

# DATE=$(date '+%Y %m %d-%k:%M:%S')
DATE=$(date '+%k:%M:%S')

DATE_=$(echo $DATE | sed 's/ /_/g')
FILE_GIT_NUM='.git-commit-num'
GIT_NUM=1
GIT_IGNORE_FILE=

[ -e $FILE_GIT_NUM ] && {
    . $FILE_GIT_NUM
} || {
    GIT_IGNORE_FILE=.gitignore
    echo "$FILE_GIT_NUM" > $GIT_IGNORE_FILE
    git add $GIT_IGNORE_FILE > /dev/null
}

# USER=(git config user.name)
FILE="${GIT_NUM}_${BRANCH}_${USER}_${DATE_}.txt"

printf "
 \\
  \\_   \\
   (')   \\_
  / )=.---(')
o( )o( )_-\_ %.0s" $(seq $GIT_NUM) >> $FILE

git add $FILE

git commit -m "C${GIT_NUM} - ${USER} - $BRANCH - $DATE" $FILE $GIT_IGNORE_FILE && \
    echo "GIT_NUM=$((GIT_NUM + 1));" > $FILE_GIT_NUM
