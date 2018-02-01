#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "git-ogw-add-commit.sh should return 0 (1)" {
    run $SRC_DIR/git-ogw-add-commit.sh
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "master (root-commit)" ]]
    [[ "${lines[1]}" =~ "insertions" ]]
    [[ "${lines[2]}" =~ "create mode" ]]
}

@test "git-ogw-add-commit.sh should leave a clean wt after the first commit" {
    $SRC_DIR/git-ogw-add-commit.sh > /dev/null

    run oglIsClean
    [ $status -eq 0 ]
}

@test "git-ogw-add-commit.sh should leave a clean wt after two commits" {
    $SRC_DIR/git-ogw-add-commit.sh > /dev/null
    $SRC_DIR/git-ogw-add-commit.sh > /dev/null

    run oglIsClean
    [ $status -eq 0 ]
}

@test "git-ogw-add-commit.sh should not commit all staged files on first commit" {
    echo 'plop' > plop.txt
    __add plop.txt

    $SRC_DIR/git-ogw-add-commit.sh > /dev/null

    run oglHasUncommittedChange
    [ $status -eq 0 ]
}

@test "git-ogw-add-commit.sh should not commit all staged files on second commit" {
    echo 'plop' > plop.txt
    __add plop.txt

    $SRC_DIR/git-ogw-add-commit.sh > /dev/null
    $SRC_DIR/git-ogw-add-commit.sh > /dev/null

    run oglHasUncommittedChange
    [ $status -eq 0 ]
}

@test "git-ogw-add-commit.sh should add exactly one commit" {
    $SRC_DIR/git-ogw-add-commit.sh > /dev/null

    run git rev-list --count master
    [ $status -eq 0 ]
    [ "$output" == 1 ]

    $SRC_DIR/git-ogw-add-commit.sh > /dev/null

    run git rev-list --count master
    [ $status -eq 0 ]
    [ "$output" == 2 ]
}

@test "git-ogw-add-commit.sh with env var USER modified" {
    USER='2xeiwhw8cf9rvae' $SRC_DIR/git-ogw-add-commit.sh > /dev/null

    run git log
    [ $status -eq 0 ]
    [[ "$output" =~ '2xeiwhw8cf9rvae' ]]
}
