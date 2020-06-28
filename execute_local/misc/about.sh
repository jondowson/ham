#!/usr/local/bin/bash

# script_name: about.sh
# author: jd
# about: functions for the about menu options

function about_ham(){

menu_check "top" "${1}"

white "-b" "Application Name:"
info "H.A.M (Handy Amazon Menu)"
echo ""

white "-b" "Version:"
info "${VERSION}"
echo ""

white "-b" "Code repository:"
info "${CODE_HOME}"
echo ""

white "-b" "Authors:"
info "Jon Dowson"
info "Damian Wloch"
echo ""

white "-b" "About:"
info "Handy Amazon Menu"
info "tested on Ubuntu and Mac flavours of linux"
info "library of bash/python scripts presented via a simple menu"
info "facilitates easy management of AWS resources by making use of AWS command-line calls"
info "no more hunting around for IP addresses - connect a ssh shell to any server - even if its IP has just changed"
info "easily and quickly build new AWS servers from HAM's simple menu driven interface"
info "HAM includes some useful handy tools for file search and file transfer"
info "easily extend HAM to capture your complex stop/start processes to save developer time whilst reducing errors"
echo ""

white "-b" "Prerequisites:"
info "Python 2.7.x"
info "Amazon AWS CLI"
info "Boto - AWS python SDK"
info "Bash that supports associative arrays - Bash 4.0 or higher"
echo ""

white "-b" "Setup:"
info "please refer to: ${SCRIPT_HOME}README.md"

menu_check "bottom" "${1}"
}

# -----------------------------------------------------------------------------------

function edit_config(){

nano "${ADMIN}""ham_config.sh"
}

# -----------------------------------------------------------------------------------

function check4update(){

menu_check "top" "${1}"

update="false"
currentDirectory="${PWD}"
cd "${HAM_HOME}"
info "current version of HAM: ${VERSION}"
echo ""

info "checking HAM's remote master branch for fresh commits"
git_check_4update | grep "behind" && update="true"

if [ "${update}" == "true" ]; then
    echo ""
    cyan "-b" "HAM updates are available to retrieve !!"
    echo "Do you want to retrieve now (y/n)"
    read updateNow
    if [ "${updateNow}" == "y" ] || [ "${updateNow}" == "Y" ] || [ "${updateNow}" == "yes" ]; then
        git_pull "master"
        echo ""
        check "Your version of HAM has been updated"
        echo ""
        info "Now exiting - restart HAM to use new version"
        exit
    fi
else
    echo ""
    check "You are already running the latest version of HAM: ${VERSION}"
fi
cd "${currentDirectory}"

menu_check "bottom" "${1}"
}
