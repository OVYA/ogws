#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglIsBranchExists() on empty dir of branch master should return 0" {

    run oglIsBranchExists master
    [ "$status" -eq 0 ]
}

@test "oglIsBranchExists() on empty dir of branch plop should return 1" {

    run oglIsBranchExists plop
    [ "$status" -eq 1 ]
}

@test "oglIsBranchExists() of existing branch should return 0 (1)" {
    __addCommit

    run oglIsBranchExists master
    [ "$status" -eq 0 ]
}

@test "oglIsBranchExists() of existing branch should return 0 (2)" {
    __addCommit
    __push master

    run oglIsBranchExists origin/master
    [ "$status" -eq 0 ]
}

@test "oglIsBranchExists() of existing branch should return 0 (3)" {
    __addCommit
    __createBranch plop

    run oglIsBranchExists plop
    [ "$status" -eq 0 ]
}

@test "oglIsBranchExists() of existing branch should return 0 (4)" {
    __addCommit
    __createBranch plop
    __push plop

    run oglIsBranchExists origin/plop
    [ "$status" -eq 0 ]
}

@test "oglIsBranchExists() of existing branch should return 0 (5)" {
    __addCommit
    __createBranch plop
    __push plop

    oglIsBranchExists plop > /dev/null 2>&1

    run oglGetBranch
    [ $output == 'master' ]
}

@test "oglIsBranchExists() of non existing branch should return 1 (1)" {
    __addCommit

    run oglIsBranchExists origin/master
    [ "$status" -eq 1 ]
}

@test "oglIsBranchExists() of non existing branch should return 1 (2)" {
    __addCommit
    __createBranch plop

    run oglIsBranchExists origin/plop
    [ "$status" -eq 1 ]
}

@test "oglIsBranchExists() of non existing branch should return 1 (3)" {
    __addCommit

    run oglIsBranchExists vsdkmoklmdvs
    [ "$status" -eq 1 ]
}

@test "oglIsBranchExists() of non existing branch should return 1 (4)" {
    __addCommit
    git tag -a plop -m "plop tag" > /dev/null 2>&1
    __addCommit

    run oglIsBranchExists plop
    [ "$status" -eq 1 ]
}
