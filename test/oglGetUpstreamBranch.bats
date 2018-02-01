#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglGetUpstreamBranch() on tracking branch (1)" {
    __addCommit
    __push master

    run oglGetUpstreamBranch
    [ "$output" == "origin/master" ]
}

@test "oglGetUpstreamBranch() on tracking branch (2)" {
    __addCommit
    __push master

    run oglGetUpstreamBranch master
    [ "$output" == "origin/master" ]
}

@test "oglGetUpstreamBranch() on tracking branch (3)" {
    __addCommit
    __push master
    __createBranch plop --track

    run oglGetUpstreamBranch plop
    [ "$output" == "master" ]
}

@test "oglGetUpstreamBranch() on tracking branch (4)" {
    __addCommit
    __push master
    __createBranch plop --track
    __gotoBranch plop

    run oglGetUpstreamBranch
    [ "$output" == "master" ]
}

@test "oglGetUpstreamBranch() on tracking branch (5)" {
    __addCommit
    __push master
    __createBranch plop --track
    __gotoBranch plop
    __createBranch plap
    __push plap
    git branch --set-upstream-to=origin/plap plap > /dev/null 2>&1

    run oglGetUpstreamBranch plap
    [ "$output" == "origin/plap" ]
}

@test "oglGetUpstreamBranch() on tracking branch (6)" {
    __addCommit
    __push master
    __checkout -b plip origin/master

    run oglGetUpstreamBranch plip
    [ "$output" == "origin/master" ]
}

@test "oglGetUpstreamBranch() on non tracking branch should output empty string and error" {
    __addCommit

    run oglGetUpstreamBranch master
    [ "$output" == "Branch 'master' does not follow an upstream branch" ]
    [ "${lines[1]}" == "" ]
}
