#!/usr/local/bin/bash

# script_name: git.sh
# author: jd
# about: variety of git functions


function git_check_4update(){

git remote update
git status -uno
}

function git_pull(){

branch=${1}

git pull origin "${branch}"
}
