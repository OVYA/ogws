#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "git-ogw-feature-close.sh should return 0 and branche deleted (1)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __checkout master

    run $SRC_DIR/git-ogw-feature-close.sh -dy 1234
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]
    [[ $output =~ 'Fix #1234' ]]
}

@test "git-ogw-feature-close.sh should return 0 and branche deleted (2)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __checkout master

    $SRC_DIR/git-ogw-feature-close.sh -dy 1234

    run __isBranchAllreadyMergedToMaster 1234
    echo $output
    [ "$status" -eq 1 ]
}

@test "git-ogw-feature-close.sh should return 0 and branche deleted (3)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __checkout master

    $SRC_DIR/git-ogw-feature-close.sh -dy 1234

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]
}


@test "git-ogw-feature-close.sh should return 0 (1)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __checkout master

    run $SRC_DIR/git-ogw-feature-close.sh -y 1234
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]
    [[ $output =~ 'Fix #1234' ]]

    run __isBranchAllreadyMergedToMaster 1234
    echo $output
    [ "$status" -eq 0 ]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]
}

@test "git-ogw-feature-close.sh should return 0 (2)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master

    run $SRC_DIR/git-ogw-feature-close.sh -y 1234
    echo $output
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]
    [[ $output =~ 'rebase' ]]
    [[ $output =~ 'Fix #1234' ]]

    run __isBranchAllreadyMergedToMaster 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]
}

@test "git-ogw-feature-close.sh should return 0 (3)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]

    run $SRC_DIR/git-ogw-feature-close.sh -yd 1234
    echo $output
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]
    [[ $output =~ 'rebase' ]]
    [[ $output =~ 'Fix #1234' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]
}

@test "git-ogw-feature-close.sh should return 0 (4)" {
    __addCommit
    __push master
    __checkout -b 1234 origin/master
    __addCommit
    __push 1234
    __checkout master
    __addCommit

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]

    run $SRC_DIR/git-ogw-feature-close.sh -y 1234
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]
    [[ $output =~ 'Fix #1234' ]]

    run __isBranchAllreadyMergedToMaster 1234
    echo $output
    [ "$status" -eq 0 ]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]
}

@test "git-ogw-feature-close.sh should return 0 (5)" {
    __addCommit
    __push master
    __checkout -b 1234 origin/master
    __addCommit
    __push 1234
    __checkout master
    __addCommit

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]

    run $SRC_DIR/git-ogw-feature-close.sh -yd 1234
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]
    [[ $output =~ 'Fix #1234' ]]
    [[ $output =~ 'rebase' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]
}


@test "git-ogw-feature-close.sh should return 0 (6)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __checkout 1234

    run $SRC_DIR/git-ogw-feature-close.sh -y 1234
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]
    [[ $output =~ 'Fix #1234' ]]
    [[ $output =~ 'rebase' ]]

    run __isBranchAllreadyMergedToMaster 1234
    echo $output
    [ "$status" -eq 0 ]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]

    run oglGetBranch
    [[ $output =~ 'master' ]]
}

@test "git-ogw-feature-close.sh should return 0 (7)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __addNewWorkTreeAndPushCommitsTo 1234
    __addNewWorkTreeAndPushCommitsTo master
    __fetch

    $SRC_DIR/git-ogw-feature-close.sh -y 1234

    run oglGetDivergenceStatus 1234 origin/1234
    [ "$output" == 'IS_EQUAL' ]
    # [ "$output" == 'HAS_DIVERGED' ]
}

@test "git-ogw-feature-close.sh should return 0 (8)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __addCommit
    __addNewWorkTreeAndPushCommitsTo 1234
    __addNewWorkTreeAndPushCommitsTo master

    $SRC_DIR/git-ogw-feature-close.sh -y 1234

    run __isBranchAllreadyMergedToMaster 1234
    [ "$status" -eq 0 ]
}

@test "git-ogw-feature-close.sh should return 1 and branches not deleted (1)" {
    __addCommit
    __push master
    __checkout -b 1234 origin/master
    __addCommit
    __push 1234
    __checkout master
    __merge 1234
    __checkout 1234

    run $SRC_DIR/git-ogw-feature-close.sh -y 1234
    [ "$status" -eq 1 ]
    [[ $output =~ 'manually' ]]
    [[ ! $output =~ 'Fix #1234' ]]
}

@test "git-ogw-feature-close.sh should return 1 and branches not deleted (2)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __merge 1234
    __addNewWorkTreeAndPushCommitsTo 1234

    $SRC_DIR/git-ogw-feature-close.sh -y 1234 || true

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]

    run oglGetBranch
    [[ $output =~ 'master' ]]
}

@test "git-ogw-feature-close.sh should return 1 and branches not deleted (1)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __merge 1234

    run $SRC_DIR/git-ogw-feature-close.sh -y 1234
    echo $output
    [ "$status" -eq 1 ]
    [[ $output =~ 'already been merged into master' ]]
    [[ ! $output =~ 'Fix #1234' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]
}
