#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglIsBranchNeedUpdate() with an empty git work tree should return 0" {
    run oglIsBranchNeedUpdate
    [ "$status" -eq 1 ]
    [ "$output" == "Branch 'master' does not follow an upstream branch" ]
}

@test "oglIsBranchNeedUpdate() without argument after commit should return 1" {
    __addCommit
    __push master
    __addCommit

    run oglIsBranchNeedUpdate
    [ "$status" -eq 1 ]
}

@test "oglIsBranchNeedUpdate() without argument after git add should return 1" {
    __addCommit
    __push master
    echo 'plop' > plop.txt && git add plop.txt > /dev/null

    run oglIsBranchNeedUpdate
    echo $output
    [ "$status" -eq 1 ]
}

@test "oglIsBranchNeedUpdate() without argument after git push should return 1" {
    __addCommit

    __push master

    run oglIsBranchNeedUpdate
    echo $output
    [ "$status" -eq 1 ]
}

@test "oglIsBranchNeedUpdate() with a new up-to-date branch should return 1" {

    __addCommit
    __push master
    __createBranch plop --track
    __gotoBranch plop

    run oglIsBranchNeedUpdate plop
    echo $output
    [ "$status" -eq 1 ]
}

@test "oglIsBranchNeedUpdate() with a new branch without upstream should return 1" {

    __addCommit
    __push master
    __createBranch plop
    __gotoBranch plop

    run oglIsBranchNeedUpdate plop
    echo $output
    [ "$status" -eq 1 ]
    [ "$output" == "Branch 'plop' does not follow an upstream branch" ]
}

@test "oglIsBranchNeedUpdate() with a new branch specifing remote branch should return 1 (1)" {

    __addCommit
    __push master
    __createBranch plop
    __gotoBranch plop

    run oglIsBranchNeedUpdate plop master
    [ "$status" -eq 1 ]
}

@test "oglIsBranchNeedUpdate() with a new branch specifing remote branch should return 1 (2)" {

    __addCommit
    __push master
    __createBranch plop
    __gotoBranch plop

    run oglIsBranchNeedUpdate plop origin/master
    [ "$status" -eq 1 ]
}

@test "oglIsBranchNeedUpdate() without argument after git push should return 1" {
    __addCommit
    __push master

    run oglIsBranchNeedUpdate
    echo $output
    [ "$status" -eq 1 ]
}

@test "oglIsBranchNeedUpdate() without argument after fetching update should return 0" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master
    __gotoBranch master
    __fetch

    run oglIsBranchNeedUpdate
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "" ]
}

@test "oglIsBranchNeedUpdate() with argument after fetching update (1)" {
    __addCommit
    __push master
    __createBranch plop
    __gotoBranch plop
    __addCommit
    __push plop:master

    ## origin/master is ahead of master
    run oglIsBranchNeedUpdate master origin/master
    echo $output
    [ "$status" -eq 0 ]

}

@test "oglIsBranchNeedUpdate() with argument after fetching update (2)" {
    __addCommit
    __push master
    __createBranch plop
    __gotoBranch plop
    __addCommit
    __push plop:master

    run oglIsBranchNeedUpdate origin/master master
    echo $output
    [ "$status" -eq 1 ]
}

@test "oglIsBranchNeedUpdate() with argument after fetching update (3)" {
    __addCommit
    __push master
    __createBranch plop
    __gotoBranch plop
    __addCommit
    __push plop:master

    run oglIsBranchNeedUpdate plop origin/master
    [ "$status" -eq 1 ]
}


@test "oglIsBranchNeedUpdate() with argument after fetching + merging (1)" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master

    __gotoBranch master
    __merge origin/master

    run oglIsBranchNeedUpdate master
    [ "$status" -eq 1 ]
}

@test "oglIsBranchNeedUpdate() with argument after fetching + merging (2)" {
    __addCommit
    __createBranch plop --track
    __gotoBranch plop
    __addCommit
    __push plop:master

    __gotoBranch master
    __merge origin/master

    run oglIsBranchNeedUpdate master plop
    [ "$status" -eq 1 ]
}
