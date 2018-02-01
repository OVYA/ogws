#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglGetDivergenceStatus() return 1 and IS_NOT_TRACKING (1)" {
    run oglGetDivergenceStatus
    [ "$status" -eq 1 ]
    [ "${lines[0]}" == "Branch 'master' does not follow an upstream branch" ]
    [ "${lines[1]}" == "IS_NOT_TRACKING" ]
}

@test "oglGetDivergenceStatus() should return 1 and IS_NOT_TRACKING (2)" {
    __addCommit

    run oglGetDivergenceStatus
    [ "$status" -eq 1 ]
    [ "${lines[0]}" == "Branch 'master' does not follow an upstream branch" ]
    [ "${lines[1]}" == "IS_NOT_TRACKING" ]
}

@test "oglGetDivergenceStatus() should return 1 and IS_NOT_TRACKING (3)" {
    __addCommit
    __push master
    __createBranch plop

    run oglGetDivergenceStatus plop
    [ "$status" -eq 1 ]
    [ "${lines[0]}" == "Branch 'plop' does not follow an upstream branch" ]
    [ "${lines[1]}" == "IS_NOT_TRACKING" ]
}

@test "oglGetDivergenceStatus() should return 1 and IS_NOT_APPLICABLE" {
    __addCommit
    __push master
    __createBranch plop

    run oglGetDivergenceStatus plap
    [ "$status" -eq 1 ]
    echo $output
    [ "${lines[0]}" == "Branch 'plap' does not exist" ]
    [ "${lines[1]}" == "IS_NOT_APPLICABLE" ]
}


@test "oglGetDivergenceStatus() with an up-to-date work tree should return IS_EQUAL (1)" {
    __addCommit
    __push master

    run oglGetDivergenceStatus
    [ "$status" -eq 0 ]
    [ "$output" == "IS_EQUAL" ]
}


@test "oglGetDivergenceStatus() with an up-to-date work tree should return IS_EQUAL (2)" {
    __addCommit
    __push master
    __checkout -b plop origin/master

    run oglGetDivergenceStatus
    [ "$status" -eq 0 ]
    [ "$output" == "IS_EQUAL" ]
}

@test "oglGetDivergenceStatus() with an up-to-date work tree should return IS_EQUAL (3)" {
    __addCommit
    __push master
    __checkout -b plop origin/master
    __gotoBranch master

    run oglGetDivergenceStatus plop
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "IS_EQUAL" ]
}

@test "oglGetDivergenceStatus() with an up-to-date work tree should return IS_EQUAL (4)" {
    __addCommit
    __push master
    __checkout -b plop origin/master
    __addCommit
    __push plop:master
    __gotoBranch master

    run oglGetDivergenceStatus plop origin/master
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "IS_EQUAL" ]
}

@test "oglGetDivergenceStatus() with an up-to-date work tree should return IS_EQUAL (5)" {
    __addCommit
    __push master
    __checkout -b plop origin/master
    __addCommit
    __push plop:master
    __gotoBranch master

    run oglGetDivergenceStatus origin/master plop
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "IS_EQUAL" ]
}

@test "oglGetDivergenceStatus() should return IS_AHEAD (1)" {
    __addCommit
    __push master
    __checkout -b plop origin/master
    __addCommit
    __gotoBranch master

    run oglGetDivergenceStatus plop
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "IS_AHEAD" ]
}

@test "oglGetDivergenceStatus() should return IS_AHEAD (2)" {
    __addCommit
    __push master
    __checkout -b plop master
    __addCommit
    __push plop:master

    run oglGetDivergenceStatus origin/master master
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "IS_AHEAD" ]
}

@test "oglGetDivergenceStatus() should return IS_BEHIND (1)" {
    __addCommit
    __push master
    __checkout -b plop origin/master
    __gotoBranch master
    __addCommit
    __push master

    run oglGetDivergenceStatus plop
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "IS_BEHIND" ]
}

@test "oglGetDivergenceStatus() should return IS_BEHIND (2)" {
    __addCommit
    __push master
    __checkout -b plop master
    __addCommit
    __push plop:master

    run oglGetDivergenceStatus master origin/master
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "IS_BEHIND" ]
}

@test "oglGetDivergenceStatus() should return IS_BEHIND (3)" {
    __addCommit
    __push master
    __checkout -b plop master
    __addCommit
    __push plop:master

    run oglGetDivergenceStatus master origin/master
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "IS_BEHIND" ]
}

@test "oglGetDivergenceStatus() should return IS_BEHIND (4)" {
    __addCommit
    __push master
    __checkout -b plop
    __addCommit
    __push plop:master

    run oglGetDivergenceStatus master
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "IS_BEHIND" ]
}

@test "oglGetDivergenceStatus() should return HAS_DIVERGED (1)" {
    __addCommit
    __push master
    __checkout -b plop origin/master
    __addCommit
    __gotoBranch master
    __addCommit
    __push master

    run oglGetDivergenceStatus plop
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "HAS_DIVERGED" ]
}

@test "oglGetDivergenceStatus() should return HAS_DIVERGED (2)" {
    __addCommit
    __push master
    __checkout -b plop master
    __addCommit
    __push plop:master
    __gotoBranch master
    __addCommit

    run oglGetDivergenceStatus master origin/master
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "HAS_DIVERGED" ]
}

@test "oglGetDivergenceStatus() should return HAS_DIVERGED (3)" {
    __addCommit
    __push master
    __checkout -b plop master
    __addCommit
    __push plop:master
    __gotoBranch master
    __addCommit

    run oglGetDivergenceStatus origin/master master
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" == "HAS_DIVERGED" ]
}
