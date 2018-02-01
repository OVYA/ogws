#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "git-ogw-master-update.sh should return 0" {
    __addCommit

    run $SRC_DIR/git-ogw-master-update.sh
    [ "$status" -eq 0 ]
}

@test "git-ogw-master-update.sh should rebase when master is behind (1)" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master

    run $SRC_DIR/git-ogw-master-update.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ 'rewinding head to replay your work on top' ]]

}

@test "git-ogw-master-update.sh should rebase when master is behind (2)" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master

    $SRC_DIR/git-ogw-master-update.sh

    run oglIsBranchUpToDate master
    [ "$status" -eq 0 ]
}

@test "git-ogw-master-update.sh should rebase when master has diverged (1)" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master
    __addCommit

    run $SRC_DIR/git-ogw-master-update.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ 'rewinding head to replay your work on top' ]]
}


@test "git-ogw-master-update.sh should rebase when master has diverged (2)" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master
    __addCommit

    $SRC_DIR/git-ogw-master-update.sh

    run oglIsBranchUpToDate master
    [ "$status" -eq 0 ]
}

@test "git-ogw-master-update.sh should not rebase when master is ahead (1)" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master
    __addCommit
    __fetch
    __merge origin/master
    __addCommit

    run $SRC_DIR/git-ogw-master-update.sh
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ 'rewinding' ]]
}

@test "git-ogw-master-update.sh should not rebase when master is ahead (2)" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master
    __addCommit
    __fetch
    __merge origin/master
    __addCommit

    $SRC_DIR/git-ogw-master-update.sh

    run oglGetDivergenceStatus master
    [ "$status" -eq 0 ]
    [[ "$output" == 'IS_AHEAD' ]]
}

@test "git-ogw-master-update.sh should not change the current branch" {
    __addCommit
    __push master
    __addNewWorkTreeAndPushCommitsTo master
    __addCommit
    __checkout -b plop

    $SRC_DIR/git-ogw-master-update.sh

    run oglGetBranch
    [ "$status" -eq 0 ]
    [[ "$output" == 'plop' ]]
}
