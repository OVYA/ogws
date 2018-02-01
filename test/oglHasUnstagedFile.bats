#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglHasUnstagedFile() on unknown branch should return 1" {
    __addCommit

    run oglHasUnstagedFile plop
    [ "$status" -eq 1 ]
}

@test "oglHasUnstagedFile() should return 1 on clean and empty warok tree" {
    run oglHasUnstagedFile
    [ "$status" -eq 1 ]
}

@test "oglHasUnstagedFile() should return 1 on clean wk (1)" {
    __addCommit

    run oglHasUnstagedFile
    [ "$status" -eq 1 ]
}

@test "oglHasUnstagedFile() should return 1 on clean wk (2)" {
    __addCommit
    __checkout -b plop
    __addCommit
    __gotoBranch master

    run oglHasUnstagedFile plop
    [ "$status" -eq 1 ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    [ "$output" == 'master' ]
}

@test "oglHasUnstagedFile() should return 0 (1)" {
    __addCommit
    echo 'plop' > plop.txt
    __addCommit

    run oglHasUnstagedFile
    [ "$status" -eq 0 ]
}

@test "oglHasUnstagedFile() should return 0 (2)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    __gotoBranch master

    run oglHasUnstagedFile plop
    [ "$status" -eq 0 ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    [ "$output" == 'master' ]
}

@test "oglHasUnstagedFile() should return 1 on uncommitted change wt (1)" {
    __addCommit
    echo 'plop' > plop.txt
    __add plop.txt
    __addCommit

    run oglHasUnstagedFile
    [ "$status" -eq 1 ]
}

@test "oglHasUnstagedFile() should return 1 on uncommitted change wt (2)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    __add plop.txt
    __gotoBranch master

    run oglHasUnstagedFile plop
    [ "$status" -eq 1 ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    [ "$output" == 'master' ]
}

@test "oglHasUnstagedFile() should return 0 on HAS_UNSTAGED_FILE,HAS_UNCOMMITTED_CHANGE wt (1)" {
    __addCommit
    echo 'plop' > plop.txt
    touch plip.txt
    __add plip.txt
    __addCommit

    run oglHasUnstagedFile
    [ "$status" -eq 0 ]
}

@test "oglHasUnstagedFile() should return 0 on HAS_UNSTAGED_FILE,HAS_UNCOMMITTED_CHANGE wt (2)" {
    __addCommit
    __checkout -b plop
    __addCommit
    touch plop.txt
    touch plip.txt
    __add plip.txt
    __gotoBranch master

    run oglHasUnstagedFile plop
    [ "$status" -eq 0 ]

    run oglGetBranch
    [ "$status" -eq 0 ]
    [ "$output" == 'master' ]
}
