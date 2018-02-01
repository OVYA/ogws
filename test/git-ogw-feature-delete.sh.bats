#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "git-ogw-feature-delete.sh should return 1 and branche not deleted" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __checkout master
    __merge 1234

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    echo $output
    [ "$status" -eq 1 ]
    [[ $output =~ 'manually' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]
}

@test "git-ogw-feature-delete.sh should return 0 and branche deleted" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __checkout master
    __merge 1234
    __push 1234

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    echo $output
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]

    # [[ "${lines[0]}" =~ "master (root-commit)" ]]
    # [[ "${lines[1]}" =~ "insertions" ]]
    # [[ "${lines[2]}" =~ "create mode" ]]
}

@test "git-ogw-feature-delete.sh should return 0 and branches deleted (1)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __merge 1234

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]
}

@test "git-ogw-feature-delete.sh should return 0 and branches deleted (2)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __merge 1234
    __checkout master
    __addCommit

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]
}

@test "git-ogw-feature-delete.sh should return 0 and branches deleted (3)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __merge 1234
    __checkout 1234

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]

    run oglGetBranch
    [[ $output =~ 'master' ]]
}

@test "git-ogw-feature-delete.sh should return 0 and branches deleted (4)" {
    __addCommit
    __push master
    __checkout -b 1234 origin/master
    __addCommit
    __push 1234
    __checkout master
    __merge 1234
    __checkout 1234
    __push master

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    echo $output
    [ "$status" -eq 0 ]
    [[ ! $output =~ 'ERROR' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]

    run oglIsBranchExists origin/master
    [ "$status" -eq 0 ]

    run oglGetBranch
    [[ $output =~ 'master' ]]
}

@test "git-ogw-feature-delete.sh should return 0 and branches deleted (5)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __merge 1234
    __addCommit
    __push master

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]

    run oglGetBranch
    [[ $output =~ 'master' ]]
}

@test "git-ogw-feature-delete.sh -x should return 0 and branches deleted (6)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __merge 1234
    __push 1234
    __addNewWorkTreeAndPushCommitsTo 1234

    run $SRC_DIR/git-ogw-feature-delete.sh -xy 1234
    [ "$status" -eq 0 ]
    [[ $output =~ "WARNING" ]]
    [[ $output =~ 'Not checking if 1234 is up-to-date' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 1 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]

    run oglGetBranch
    [[ $output =~ 'master' ]]
}

@test "git-ogw-feature-delete.sh should return 1 and branches not deleted (1)" {
    __addCommit
    __push master
    __checkout -b 1234 origin/master
    __addCommit
    __push 1234
    __checkout master
    __merge 1234
    __checkout 1234

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    [ "$status" -eq 1 ]
    [[ $output =~ 'not fully merged' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/master
    [ "$status" -eq 0 ]

    run oglGetBranch
    echo $output
    [[ $output == '1234' ]]
}

@test "git-ogw-feature-delete.sh should return 1 and branches not deleted (2)" {
    __addCommit
    __push master
    __checkout -b 1234
    __addCommit
    __push 1234
    __checkout master
    __merge 1234
    __addNewWorkTreeAndPushCommitsTo 1234

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    [ "$status" -eq 1 ]
    [[ $output =~ "'1234' IS_BEHIND regarding origin/1234" ]]
    [[ $output =~ 'not up-to-date' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 0 ]

    run oglGetBranch
    [[ $output =~ 'master' ]]
}

@test "git-ogw-feature-delete.sh should return 1 and branches not deleted (3)" {
    __addCommit
    __push master
    __checkout -b 1234 origin/master
    __addCommit
    __checkout master
    __merge 1234
    __checkout 1234
    __addCommit

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    [ "$status" -eq 1 ]
    # echo $output
    [[ $output =~ "'1234' IS_AHEAD regarding master" ]]
    [[ $output =~ 'not up-to-date' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]

    run oglGetBranch
    [[ $output =~ '1234' ]]
}

@test "git-ogw-feature-delete.sh should return 1 and branches not deleted (3)" {
    __addCommit
    __push master
    __checkout -b 1234 origin/master
    __addCommit
    __checkout master
    __merge 1234
    __addCommit
    __checkout 1234
    __addCommit

    run $SRC_DIR/git-ogw-feature-delete.sh -y 1234
    [ "$status" -eq 1 ]
    # echo $output
    [[ $output =~ "'1234' HAS_DIVERGED regarding master" ]]
    [[ $output =~ 'not up-to-date' ]]

    run oglIsBranchExists 1234
    [ "$status" -eq 0 ]

    run oglIsBranchExists origin/1234
    [ "$status" -eq 1 ]

    run oglGetBranch
    [[ $output =~ '1234' ]]
}
