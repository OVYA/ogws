#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglIsBranchUpToDate() with an empty git work tree should return 0" {
    run oglIsBranchUpToDate
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() without argument after commit should return 0" {
    __addCommit
    __push master
    __addCommit

    run oglIsBranchUpToDate
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() without argument after git add should return 0" {
    echo 'plop' > plop.txt && git add plop.txt > /dev/null

    run oglIsBranchUpToDate
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() without argument after git push should return 0" {
    __addCommit
    __push master

    run oglIsBranchUpToDate
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() with a new up-to-date branch  should return 0" {

    __addCommit
    __push master
    __createBranch plop --track
    __gotoBranch plop

    run oglIsBranchUpToDate plop
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() with a new branch without upstream should return 0" {

    __addCommit
    __push master
    __createBranch plop
    __gotoBranch plop

    run oglIsBranchUpToDate plop
    [ "$status" -eq 0 ]
    [ "$output" = "Branch 'plop' does not follow an upstream branch" ]
}

@test "oglIsBranchUpToDate() with a new branch specifing remote branch should return 0 (1)" {

    __addCommit
    __push master
    __createBranch plop
    __gotoBranch plop

    run oglIsBranchUpToDate plop master
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() with a new branch specifing remote branch should return 0 (2)" {

    __addCommit
    __push master
    __createBranch plop
    __gotoBranch plop

    run oglIsBranchUpToDate plop origin/master
    [ "$status" -eq 0 ]
}


@test "oglIsBranchUpToDate() without argument after fetching update should return 1" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master
    __gotoBranch master
    __fetch

    run oglIsBranchUpToDate
    [ "$status" -eq 1 ]
    echo $output
    [ "$output" == "" ]
}

@test "oglIsBranchUpToDate() with argument after fetching update (1)" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master

    run oglIsBranchUpToDate master origin/master
    [ "$status" -eq 1 ]
}

@test "oglIsBranchUpToDate() with argument after fetching update (2)" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master

    run oglIsBranchUpToDate plop origin/master
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() with argument after fetching update (3)" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master

    run oglIsBranchUpToDate plop origin/master
    echo $output
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() with argument after fetching update (4)" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master

    run oglIsBranchUpToDate plop master
    echo $output
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() with argument after fetching + merging (1)" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master

    __gotoBranch master
    __merge origin/master

    run oglIsBranchUpToDate master
    [ "$status" -eq 0 ]
}

@test "oglIsBranchUpToDate() with argument after fetching + merging (2)" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master

    __gotoBranch master
    __merge origin/master

    run oglIsBranchUpToDate master plop
    [ "$status" -eq 0 ]
}
