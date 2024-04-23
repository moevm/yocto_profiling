#! /bin/bash

cd ..

pylint --rcfile=linter/.pylintrc $(git ls-files './*.py')