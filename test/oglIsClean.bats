#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglIsClean() on unknown branch should return 1" {
    __addCommit

    run oglIsClean plop
    [ "$status" -eq 1 ]
    [ "${lines[0]}" == "Branch 'plop' does not exist" ]
}

@test "oglIsClean() on empty work tree should return 0" {
    run oglIsClean

    [ "$status" -eq 0 ]
}

@test "oglIsClean() should return 0 (1)" {
    __addCommit

    run oglIsClean
    [ "$status" -eq 0 ]
}

@test "oglIsClean() should return 0" {
    __addCommit
    __checkout -b plop
    __addCommit
    __gotoBranch master

    run oglIsClean plop
    [ "$status" -eq 0 ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    echo $output
    [ "$output" == 'master' ]
}

@test "oglIsClean() should return 1 (1)" {
    __addCommit
    echo 'plop' > plop.txt
    __addCommit

    run oglIsClean
    [ "$status" -eq 1 ]
}

@test "oglIsClean() should return 1 (2)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    __gotoBranch master

    run oglIsClean plop
    [ "$status" -eq 1 ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    [ "$output" == 'master' ]
}

@test "oglIsClean() should return 1" {
    __addCommit
    echo 'plop' > plop.txt
    __add plop.txt
    __addCommit

    run oglIsClean
    [ "$status" -eq 1 ]
}

@test "oglIsClean() should return 1 (3)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    __add plop.txt
    __gotoBranch master

    run oglIsClean plop
    [ "$status" -eq 1 ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    echo $output
    [ "$output" == 'master' ]
}

@test "oglIsClean() should return 1 (4)" {
    __addCommit
    echo 'plop' > plop.txt
    touch plip.txt
    __add plip.txt
    __addCommit

    run oglIsClean
    [ "$status" -eq 1 ]
}

@test "oglIsClean() should return 1 (5)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    touch plip.txt
    __add plip.txt
    __gotoBranch master

    run oglIsClean plop
    [ "$status" -eq 1 ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    echo $output
    [ "$output" == 'master' ]
}
