#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

load ../lib/bsfl

# confirm()
# --------------------------------------------------------------#

@test "confirm() reading y should return 0" {
    run confirm <<< "y"
    [ "$status" -eq 0 ]

}

@test "confirm() reading Y should return 0" {
    run confirm <<< "Y"
    [ "$status" -eq 0 ]
}

@test "confirm() reading n should return 1" {
    run confirm <<< "n"
    [ "$status" -eq 1 ]
}

@test "confirm() reading N should return 1" {
    run confirm <<< "N"
    [ "$status" -eq 1 ]
}

@test "confirm() message should conform [y/n] by default" {
    run confirm <<< "n"
    echo "$output" | grep -q "\[y/n\]" || {
        echo "Output is '$output' instead of [y/N]"
        false
    }
}

@test "confirm() message should conform [Y/n] with option '[yY]'" {
    run confirm 'y' <<< "n"
    echo "$output" | grep -q "\[Y/n\]"

    run confirm 'Y' <<< "n"
    echo "$output" | grep -q "\[Y/n\]"
}

@test "confirm() message should conform [Y/n] with option '[yY]'" {
    run confirm 'y' <<< "n"
    echo "$output" | grep -q "\[Y/n\]"

    run confirm 'Y' <<< "n"
    echo "$output" | grep -q "\[Y/n\]"
}

@test "confirm() should return 0 with option '[yY]' and empty input" {
    run confirm "y" <<< ""
    [ "$status" -eq 0 ]

    run confirm "Y" <<< ""
    [ "$status" -eq 0 ]
}

@test "confirm() should return 0 with option '[yY]' and empty input" {
    run confirm "y" <<< ""
    [ "$status" -eq 0 ]

    run confirm "Y" <<< ""
    [ "$status" -eq 0 ]
}


@test "confirm() should return 1 with option '[nN]' and empty input" {
    run confirm "n" <<< ""
    [ "$status" -eq 1 ]

    run confirm "N" <<< ""
    [ "$status" -eq 1 ]
}

@test "read_path()" {
    run read_path "/usr/local" THEPATH <<< "/usr/local"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    read_path "/usr/local" THEPATH <<< "/usr/local"
    [ "$THEPATH" = "/usr/local" ]
}
