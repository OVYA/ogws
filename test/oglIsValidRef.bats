#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglIsValidRef() of existing branch should return 0 (1)" {
    __addCommit

    run oglIsValidRef master
    [ "$status" -eq 0 ]
}

@test "oglIsValidRef() of existing branch should return 0 (2)" {
    __addCommit
    __push master

    run oglIsValidRef origin/master
    [ "$status" -eq 0 ]

}

@test "oglIsValidRef() of existing branch should return 0 (3)" {
    __addCommit
    __createBranch plop

    run oglIsValidRef plop
    [ "$status" -eq 0 ]
}

@test "oglIsValidRef() of existing branch should return 0 (4)" {
    __addCommit
    __push master
    __createBranch plop
    __push plop

    run oglIsValidRef origin/plop
    [ "$status" -eq 0 ]
}

@test "oglIsValidRef() of existing branch should return 0 (5)" {
    __addCommit

    run oglIsValidRef HEAD
    [ "$status" -eq 0 ]
}

@test "oglIsValidRef() of existing branch should return 0 (6)" {
    __addCommit
    __push master

    run oglIsValidRef '@{u}'
    [ "$status" -eq 0 ]
}


@test "oglIsValidRef() of existing tag should return 0 (7)" {
    __addCommit
    git tag -a plop -m "plop tag" > /dev/null 2>&1
    __addCommit

    run oglIsValidRef plop
    [ "$status" -eq 0 ]
}

@test "oglIsValidRef() of existing branch should return 0 (8)" {
    __addCommit

    run oglIsValidRef $(git log -1 --abbrev-commit --oneline | sed -E 's/ .*//g')
    [ "$status" -eq 0 ]
}

@test "oglIsValidRef() on empty dir of branch master should return 1" {

    run oglIsValidRef master
    [ "$status" -eq 1 ]
}

@test "oglIsValidRef() on empty dir of branch plop should return 1" {

    run oglIsValidRef plop
    [ "$status" -eq 1 ]
}

@test "oglIsValidRef() of non existing branch should return 1 (1)" {
    __addCommit

    run oglIsValidRef origin/master
    [ "$status" -eq 1 ]
}

@test "oglIsValidRef() of non existing branch should return 1" {
    __addCommit
    __createBranch plop

    run oglIsValidRef origin/plop
    [ "$status" -eq 1 ]
}

@test "oglIsValidRef() of non existing branch should return 1" {
    __addCommit
    run oglIsValidRef vsdkmoklmdvs
    [ "$status" -eq 1 ]
}
