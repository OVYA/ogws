#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "git-ogw-feature-update.sh should return 0 (1)" {
    __addCommit
    __push master

    $SRC_DIR/git-ogw-feature-start.sh -y 1234

    run $SRC_DIR/git-ogw-feature-update.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ ! "$output" =~ "ERROR" ]]
}

@test "git-ogw-feature-update.sh should return 0 (2)" {
    __addCommit
    __push master

    $SRC_DIR/git-ogw-feature-start.sh -y 1234

    __addCommit
    __push 1234
    __checkout master
    __addCommit
    __push master

    run $SRC_DIR/git-ogw-feature-update.sh 1234
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ ! "$output" =~ "ERROR" ]]
}

@test "git-ogw-feature-update.sh should return 0 (3)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __addNewWorkTreeAndPushCommitsTo master

    run $SRC_DIR/git-ogw-feature-update.sh
    [ "$status" -eq 0 ]
    echo $output
    [[ $output =~ "rewinding head to replay your work" ]]
    [[ $output =~ "Applying:" ]]
    [[ $output =~ "SUCCESS" ]]
    [[ ! $output =~ "ERROR" ]]
}

@test "git-ogw-feature-update.sh should return 0 (3)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __addNewWorkTreeAndPushCommitsTo master
    __checkout master

    run $SRC_DIR/git-ogw-feature-update.sh 1234
    [ "$status" -eq 0 ]
    [[ $output =~ "git checkout 1234" ]]
    [[ $output =~ "rewinding head to replay your work" ]]
    [[ $output =~ "Applying:" ]]
    [[ $output =~ "SUCCESS" ]]
    [[ ! $output =~ "ERROR" ]]
}

@test "git-ogw-feature-update.sh should leave feature=master and master up-to-date (1)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addNewWorkTreeAndPushCommitsTo master

    $SRC_DIR/git-ogw-feature-update.sh 1234

    run oglGetDivergenceStatus 1234 master
    [ "$status" -eq 0 ]
    [[ $output == 'IS_EQUAL' ]]
}

@test "git-ogw-feature-update.sh should leave feature=master and master up-to-date (2)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addNewWorkTreeAndPushCommitsTo master

    $SRC_DIR/git-ogw-feature-update.sh 1234

    run oglIsBranchUpToDate master
    [ "$status" -eq 0 ]
}

@test "git-ogw-feature-update.sh should leave feature ahead of master and master up-to-date (1)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __addCommit
    __addNewWorkTreeAndPushCommitsTo master

    $SRC_DIR/git-ogw-feature-update.sh 1234

    run oglGetDivergenceStatus 1234 master
    [ "$status" -eq 0 ]
    [[ $output == 'IS_AHEAD' ]]
}

@test "git-ogw-feature-update.sh should leave feature ahead of master and master up-to-date (2)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __addCommit
    __addNewWorkTreeAndPushCommitsTo master

    $SRC_DIR/git-ogw-feature-update.sh 1234

    run oglIsBranchUpToDate master
    [ "$status" -eq 0 ]
}
