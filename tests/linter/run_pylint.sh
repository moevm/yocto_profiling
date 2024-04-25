#! /bin/bash

cd ../..

pylint --rcfile=./tests/linter/.pylintrc $(git ls-files './*.py')
