#!/bin/bash

git remote add $1 "https://github.com/Tamir-K/$1.git"
git fetch $1
git merge -s ours --no-commit --allow-unrelated-histories $1/main
git read-tree --prefix=$1/ -u $1/main
git commit -m "Merged $1"
git push
