#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglHasUpstreamBranch() on tracking branch should return 0 (1)" {
    __commitAndPushMaster

    run oglHasUpstreamBranch
    [ "$status" -eq 0 ]
}

@test "oglHasUpstreamBranch() on tracking branch should return 0 (2)" {
    __commitAndPushMaster

    run oglHasUpstreamBranch master
    [ "$status" -eq 0 ]
}

@test "oglHasUpstreamBranch() on tracking branch should return 0 (3)" {
    __commitAndPushMaster
    __createBranch plop --track

    run oglHasUpstreamBranch plop
    [ "$status" -eq 0 ]
}

@test "oglHasUpstreamBranch() on tracking branch should return 0 (4)" {
    __commitAndPushMaster
    __createBranch plop --track

    __gotoBranch plop
    run oglHasUpstreamBranch
    [ "$status" -eq 0 ]
}

@test "oglHasUpstreamBranch() on tracking branch should return 0 (5)" {
    __commitAndPushMaster
    __createBranch plap
    __push plap

    git branch --set-upstream-to=origin/plap plap > /dev/null 2>&1

    run oglHasUpstreamBranch plap
    [ "$status" -eq 0 ]
}

@test "oglHasUpstreamBranch() on non tracking branch should return 1 (1)" {
    __addCommit

    run oglHasUpstreamBranch master
    [ "$status" -eq 1 ]
}

@test "oglHasUpstreamBranch() on non tracking branch should return 1 (2)" {
    __addCommit
    __createBranch plap

    run oglHasUpstreamBranch plap
    [ "$status" -eq 1 ]
}

@test "oglHasUpstreamBranch() on non tracking branch should return 1 (3)" {
    __addCommit
    __createBranch plap
    __push plap

    run oglHasUpstreamBranch plap
    [ "$status" -eq 1 ]
}
