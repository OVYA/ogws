#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "git-ogw-feature-push.sh should return 0" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __checkout master

    run $SRC_DIR/git-ogw-feature-push.sh 1234
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]
    [[ $output =~ 'git push' ]]
}


@test "git-ogw-feature-push.sh f-branch and origin/f-branch shoud be equal" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __addCommit
    __checkout master
    __addCommit
    __addNewWorkTreeAndPushCommitsTo master
    __addNewWorkTreeAndPushCommitsTo 1234
    __fetch

    $SRC_DIR/git-ogw-feature-update.sh 1234
    $SRC_DIR/git-ogw-feature-push.sh 1234

    run oglGetDivergenceStatus 1234 origin/1234
    [ "$output" == 'IS_EQUAL' ]
}

@test "git-ogw-feature-push.sh shoud return 1" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __addNewWorkTreeAndPushCommitsTo 1234

    run $SRC_DIR/git-ogw-feature-push.sh 1234
    [ "$status" -eq 1 ]
}
