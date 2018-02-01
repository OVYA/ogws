#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

setup() {
    SRC_DIR="${BATS_TEST_DIRNAME}/../src"
    TMP_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "git-ogw-create-repos.sh return 0 and create an enpty Git repository" {

    run bash -c "GIT_USER=$USER ROOT_DIR=$TMP_DIR $SRC_DIR/git-ogw-create-repos.sh -y plop"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Initialized empty shared" ]]
}

@test "git-ogw-create-repos.sh return 0 and manage trailing / in the root directory name" {

    run bash -c "GIT_USER=$USER ROOT_DIR=${TMP_DIR}/ $SRC_DIR/git-ogw-create-repos.sh -y plop"
    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "//" ]]
}
