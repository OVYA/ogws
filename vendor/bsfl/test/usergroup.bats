#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

load ../lib/bsfl

# is_root()
# --------------------------------------------------------------#
@test "is_root()" {
    run is_root
    [ "$output" = "" ]
    [ $EUID -eq 0 ] && [ "$status" -eq 0 ]
    [ $EUID -ne 0 ] && [ "$status" -eq 1 ]
}

# is_user_exists()
# --------------------------------------------------------------#
@test "is_user_exists() with know user root" {
    run is_user_exists root
    [ "$output" = "" ]
    [ "$status" -eq 0 ]
}

@test "is_user_exists() with current user" {
    run is_user_exists $(whoami)
    [ "$output" = "" ]
    [ "$status" -eq 0 ]
}

@test "is_user_exists() with unknown user tv5sz7ne7vjip9z" {
    run is_user_exists tv5sz7ne7vjip9z
    [ "$output" = "" ]
    [ "$status" -eq 1 ]
}