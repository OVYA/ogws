# OVYA Git Workflow Script

## Documentation

The online documentation is available [here][1].

Building the documentation is done by using [Doxygen][2] with the command `make doc`.

## Install

```sh
git submodule update --init
sudo make install
```
If you have write access to `/usr/local/bin`, there is no need to use `sudo`.

## Uninstall

`sudo make uninstall`

## Unit tests

More than 200 unit tests can be done using the command `make test`.

* Footnotes

 [1]: https://ovya.github.io/ogws/
 [2]: http://doxygen.org/
