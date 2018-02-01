#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglSwitchToBranch() and oglGetBranch()" {
    __addCommit

    run oglSwitchToBranch master
    [ "$status" -eq 0 ]

    run oglGetBranch
    [ "$output" == "master" ]

    __checkout -b plop

    run oglGetBranch
    [ "$output" == "plop" ]

    run oglSwitchToBranch master
    [ "$status" -eq 0 ]

    run oglGetBranch
    [ "$output" == "master" ]
}
