# BSFL

[![Build Status](https://travis-ci.org/SkypLabs/bsfl.svg?branch=master)](https://travis-ci.org/SkypLabs/bsfl)

The Bash Shell Function Library (BSFL) is a small bash script that
acts as a library for bash scripts. It provides a couple of functions
that makes the lives of most people using shell scripts a bit easier.

This project is a fork of the original work of Louwrentius.

## Getting started

In order to use BSFL, you have to include the library in your bash
scripts. You can do it with an absolute path :

    source <absolute path to BSFL>

For example :

    source /opt/bsfl/bsfl.sh

Or with a relative path :

    declare -r DIR=$(cd "$(dirname "$0")" && pwd)
    source $DIR/<relative path to BSFL>

For example :

    declare -r DIR=$(cd "$(dirname "$0")" && pwd)
    source $DIR/../lib/bsfl.sh

## What's next ?

The best way to learn how BSFL works is to look at the examples
available in the [examples][2] folder.

## Documentation

The online documentation is available [here][3].

Building the documentation is done by using [Doxygen][5] :

    cd <BSFL repository>/doc
    doxygen Doxyfile

or

    cd <BSFL repository>
    make doc

## Dependencies

BSFL is implemented for bash version 4. Prior versions of bash will
fail at interpreting its code.

In addition, BSFL depends of some external programs. Here is the list
of these programs :

* tr
* logger
* date
* tput
* grep
* printf
* sed
* getent
* read

However, we try to get as much as possible a standalone
library. Hence, some of these external dependencies will be removed in
the future.

## Unit tests

BSFL uses [Bats][4] testing framework to verify the correct behaviour
of its functions.

To run all the tests :

    bats <BSFL repository>/test

or

    cd <BSFL repository>
    make test

To run only the tests of a specific group :

    bats <BSFL repository>/test/<test file>

For example, for the network group :

    bats <BSFL repository>/test/network.bats

## Get involved !

This project is still under development. Contributions are welcomed.

## License

[New BSD][1]

 [1]: http://opensource.org/licenses/BSD-3-Clause
 [2]: https://github.com/SkypLabs/bsfl/tree/master/examples
 [3]: https://ovya.github.io/bsfl/
 [4]: https://github.com/sstephenson/bats
 [5]: http://doxygen.org/
