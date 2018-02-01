#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglGetStatus() on unknown branch should return 1 and IS_NOT_APPLICABLE" {
    __addCommit

    run oglGetStatus plop
    [ "$status" -eq 1 ]
    [ "${lines[0]}" == "Branch 'plop' does not exist" ]
    [ "${lines[1]}" == 'IS_NOT_APPLICABLE' ]
}

@test "oglGetStatus() should return 0 and IS_CLEAN,IS_EMPTY" {
    run oglGetStatus
    [ "$status" -eq 0 ]
    [ "$output" == 'IS_CLEAN,IS_EMPTY' ]
}

@test "oglGetStatus() should return 0 and IS_CLEAN (1)" {
    __addCommit

    run oglGetStatus
    [ "$status" -eq 0 ]
    [ "$output" == 'IS_CLEAN' ]
}

@test "oglGetStatus() should return 0 and IS_CLEAN (2)" {
    __addCommit
    __checkout -b plop
    __addCommit
    __gotoBranch master

    run oglGetStatus plop
    [ "$status" -eq 0 ]
    [ "$output" == 'IS_CLEAN' ]
}

@test "oglGetStatus() should return 0 and IS_CLEAN (3)" {
    __addCommit
    __checkout -b plop
    __addCommit
    __gotoBranch master

    oglGetStatus plop > /dev/null 2>&1
    run oglGetBranch
    [ "$status" -eq 0 ]
    [ "$output" == 'master' ]
}

@test "oglGetStatus() should return 0 and HAS_UNSTAGED_FILE (1)" {
    __addCommit
    echo 'plop' > plop.txt
    __addCommit

    run oglGetStatus
    [ "$status" -eq 0 ]
    [ "$output" == 'HAS_UNSTAGED_FILE' ]
}

@test "oglGetStatus() should return 0 and HAS_UNSTAGED_FILE (2)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    __gotoBranch master

    run oglGetStatus plop
    [ "$status" -eq 0 ]
    [ "$output" == 'HAS_UNSTAGED_FILE' ]
}

@test "oglGetStatus() should return 0 and HAS_UNSTAGED_FILE (3)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    __gotoBranch master

    oglGetStatus plop > /dev/null 2>&1

    run oglGetBranch
    [ "$status" -eq 0 ]
    [ "$output" == 'master' ]
}

@test "oglGetStatus() should return 0 and HAS_UNCOMMITTED_CHANGE (1)" {
    __addCommit
    echo 'plop' > plop.txt
    __add plop.txt
    __addCommit

    run oglGetStatus
    [ "$status" -eq 0 ]
    [ "$output" == 'HAS_UNCOMMITTED_CHANGE' ]
}

@test "oglGetStatus() should return 0 and HAS_UNCOMMITTED_CHANGE (2)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    __add plop.txt
    __gotoBranch master

    run oglGetStatus plop
    [ "$status" -eq 0 ]
    [ "$output" == 'HAS_UNCOMMITTED_CHANGE' ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    [ "$output" == 'master' ]
}

@test "oglGetStatus() should return 0 and HAS_UNSTAGED_FILE,HAS_UNCOMMITTED_CHANGE (1)" {
    __addCommit
    echo 'plop' > plop.txt
    touch plip.txt
    __add plip.txt
    __addCommit

    run oglGetStatus
    [ "$status" -eq 0 ]
    [ "$output" == 'HAS_UNSTAGED_FILE,HAS_UNCOMMITTED_CHANGE' ]
}

@test "oglGetStatus() should return 0 and HAS_UNSTAGED_FILE,HAS_UNCOMMITTED_CHANGE (2)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    touch plip.txt
    __add plip.txt
    __gotoBranch master

    run oglGetStatus plop
    [ "$status" -eq 0 ]
    [ "$output" == 'HAS_UNSTAGED_FILE,HAS_UNCOMMITTED_CHANGE' ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    [ "$output" == 'master' ]
}
