#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglIsWorkDirEmpty() with an empty git work tree should return 0" {
    run oglIsWorkDirEmpty
    [ "$status" -eq 0 ]
}

@test "oglIsWorkDirEmpty() with an non empty git work tree should return 1" {
    __addCommit

    run oglIsWorkDirEmpty
    [ "$status" -eq 1 ]
}
