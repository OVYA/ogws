#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "git-ogw-feature-start.sh should return 0 (1)" {
    __addCommit

    run $SRC_DIR/git-ogw-feature-start.sh -y 1234
    [ "$status" -eq 0 ]
    [[ $output =~ 'git checkout -b 1234 master' ]]
}

@test "git-ogw-feature-start.sh should return 0 (2)" {
    __addCommit

    run $SRC_DIR/git-ogw-feature-start.sh -y abc_des_f-1234
    [ "$status" -eq 0 ]
    [[ $output =~ 'git checkout -b abc_des_f-1234 master' ]]
}

@test "git-ogw-feature-start.sh should return 0 (3)" {
    __addCommit
    __push master

    run $SRC_DIR/git-ogw-feature-start.sh -y 1234
    [ "$status" -eq 0 ]
    [[ $output =~ 'git checkout -b 1234 origin/master' ]]
}

@test "git-ogw-feature-start.sh should rebase and return 0" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master

    run $SRC_DIR/git-ogw-feature-start.sh -y 1234
    [ "$status" -eq 0 ]
    [[ "$output" =~ 'git rebase' ]]
}

@test "git-ogw-feature-start.sh should update the master branch and return 0 (1)" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master

    $SRC_DIR/git-ogw-feature-start.sh -y 1234

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]
}

@test "git-ogw-feature-start.sh should update the master branch and return 0 (2)" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master

    $SRC_DIR/git-ogw-feature-start.sh -y 1234

    run oglGetBranch
    [[ "$output" == '1234' ]]
}


@test "git-ogw-feature-start.sh should update the master branch and return 0 (3)" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master

    $SRC_DIR/git-ogw-feature-start.sh -y 1234

    __fetch

    run oglIsBranchUpToDate master origin/master
    [ "$status" -eq 0 ]
}

@test "git-ogw-feature-start.sh should return 1 on bad feature name" {
    __addCommit
    __push master

    run $SRC_DIR/git-ogw-feature-start.sh -y zazaa
    [ "$status" -eq 1 ]

    run $SRC_DIR/git-ogw-feature-start.sh -y zaza--123
    [ "$status" -eq 1 ]
    run $SRC_DIR/git-ogw-feature-start.sh -y za-za-123
    [ "$status" -eq 1 ]

    run $SRC_DIR/git-ogw-feature-start.sh -y -1231
    [ "$status" -eq 1 ]

    run $SRC_DIR/git-ogw-feature-start.sh -y 1234211-abvz
    [ "$status" -eq 1 ]

    run $SRC_DIR/git-ogw-feature-start.sh -y qszdsq-
    [ "$status" -eq 1 ]

    run $SRC_DIR/git-ogw-feature-start.sh -y -rere-2123
    [ "$status" -eq 1 ]

    run $SRC_DIR/git-ogw-feature-start.sh -y -2123
    [ "$status" -eq 1 ]
}
