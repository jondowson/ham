#!/usr/local/bin/bash

# script_name: format.sh
# author: jd
# about: functions for formatting screen output

# -----------------------------------------------------------------------------------
# Setup colors and text effects

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
b=`tput bold`
u=`tput sgr 0 1`
ul=`tput smul`
xl=`tput rmul`
stou=`tput smso`
xtou=`tput rmso`
reverse=`tput rev`
reset=`tput sgr0`

function head() {
    echo "${blue}${b}==>${white} $1${reset}"
}

function info() {
    echo "${blue}${b}==>${reset} $1"
}

function question() {
    echo "${blue}${b}Q.${stou}${red} $1 ${xtou}$reset"
}

function menuChoices() {
    echo "${cyan}${stou}YOUR CHOICES:${xtou} ${1}${reset}"
}

function result() {
    echo "${blue}${b}==>${yellow} $1 $reset"
}

function userChoices() {
    echo "${blue}${b}==>${red} $1"
}

function hamInfo() {
    echo "${blue}${b}=========================================>>${reset}"
}

function successHeading() {
    echo "${green}${b}==> $1${reset}"
}

function success() {
    echo "${green}${b}==>${reset}${green} $1${reset}"
}

function error() {
    echo "${red}==> ${u}${b}${red}$1${reset}"
}

function smallError() {
    echo "${red}==>${reset} $1"
}

function green() {
    if [ "${1}" == "-n" ]; then
        echo -n "${green}$2${reset}"
    elif [ "${1}" == "-nb" ] || [ "${1}" == "-bn" ]; then
        echo -n "${b}${green}$2${reset}"
    elif [ "${1}" == "-b" ]; then
        echo "${b}${green}$2${reset}"
    else
        echo "${green}$1${reset}"
    fi
}

function yellow() {
    if [ "${1}" == "-n" ]; then
        echo -n "${yellow}$2${reset}"
    elif [ "${1}" == "-nb" ] || [ "${1}" == "-bn" ]; then
        echo -n "${b}${yellow}$2${reset}"
    elif [ "${1}" == "-b" ]; then
        echo "${b}${yellow}$2${reset}"
    else
        echo "${yellow}$1${reset}"
    fi
}

function cyan() {
    if [ "${1}" == "-n" ]; then
        echo -n "${cyan}$2${reset}"
    elif [ "${1}" == "-nb" ] || [ "${1}" == "-bn" ]; then
        echo -n "${b}${cyan}$2${reset}"
    elif [ "${1}" == "-b" ]; then
        echo "${b}${cyan}$2${reset}"
    else
        echo "${cyan}$1${reset}"
    fi
}

function white() {
    if [ "${1}" == "-n" ]; then
        echo -n "${white}$2${reset}"
    elif [ "${1}" == "-nb" ] || [ "${1}" == "-bn" ]; then
        echo -n "${b}${white}$2${reset}"
    elif [ "${1}" == "-b" ]; then
        echo "${b}${white}$2${reset}"
    else
        echo "${white}$1${reset}"
    fi
}
function magenta() {
    if [ "${1}" == "-n" ]; then
        echo -n "${magenta}$2${reset}"
    elif [ "${1}" == "-nb" ] || [ "${1}" == "-bn" ]; then
        echo -n "${b}${magenta}$2${reset}"
    elif [ "${1}" == "-b" ]; then
        echo "${b}${magenta}$2${reset}"
    else
        echo "${magenta}$1${reset}"
    fi
}

function blue() {
    if [ "${1}" == "-n" ]; then
        echo -n "${blue}$2${reset}"
    elif [ "${1}" == "-nb" ] || [ "${1}" == "-bn" ]; then
        echo -n "${b}${blue}$2${reset}"
    elif [ "${1}" == "-b" ]; then
        echo "${b}${blue}$2${reset}"
    else
        echo "${blue}$1${reset}"
    fi
}

function red() {
    if [ "${1}" == "-n" ]; then
        echo -n "${red}$2${reset}"
    elif [ "${1}" == "-nb" ] || [ "${1}" == "-bn" ]; then
        echo -n "${b}${red}$2${reset}"
    elif [ "${1}" == "-b" ]; then
        echo "${b}${red}$2${reset}"
    else
        echo "${red}$1${reset}"
    fi
}

function check() {
    echo "${green}${b} ✓${reset}  $1${reset}"
}

function uncheck() {
    echo "${red}${b} ✘${reset}  $1${reset}"
}

# -----------------------------------------------------------------------------------

function menu_check(){

if [ "${1}" == "table-top" ]; then
    :

elif [ "${1}" == "table-bottom" ]; then
    if [[ "${2}" == *"@"* ]]; then
        this_menu=${2/%?/}
    else
        this_menu=${2}
    fi
    read -p "Hit [Enter] to return to menu..."
    eval ${this_menu}

elif [ "${2}" == "first" ] || [[ "${2}" == *"@"* ]] && [ "${1}" == "top" ]; then
        echo ""
        hamInfo
        echo ""
elif [ "${1}" == "bottom" ] && [[ "${2}" == *"menu_"* ]]; then
    echo ""
    hamInfo
    if [[ "${2}" == *"@"* ]]; then
        this_menu=${2/%?/}
    else
        this_menu=${2}
    fi
    read -p "Hit [Enter] to return to menu..."
    eval ${this_menu}
elif [ "${1}" == "noFormat" ]; then
    echo ""
fi
}

# -----------------------------------------------------------------------------------

