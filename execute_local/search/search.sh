#!/usr/local/bin/bash

# script_name: search.sh
# author: jd
# about: search for files over a local, aws or other remote server

# this script offers the user a choice of:
# a) conducting a search for files by name or for strings within files
# b) conducting the search on the local machine, a remote computer or from an aws server
# this script calls out to inline menus defined in the menu.sh script
# the user makes a series of choices either by selecting a menu choice or by entering text
# so that the user can go back and change a choice - a choice history is maintained.

#  -------------------------------------------------------------------------------------

# entry point for script

# searching for files
function util_search_4files(){
menu_check "top" "${1}"

menuChoices=""
next=""
previousQuestion=""
rewind="false"
searchLocation=""
searchFolder=""
userAccount=""
searchTerm=""
searchType="4files"
addMenuSelection "${searchType}"
which_location "initiate"

menu_check "bottom" "${1}"
}

# searching for strings within files
function util_search_files4strings(){
menu_check "top" "${1}"

menuChoices=""
next=""
previousQuestion=""
rewind="false"
searchLocation=""
searchFolder=""
userAccount=""
searchTerm=""
searchType="files4strings"
addMenuSelection "${searchType}"
which_location "initiate"

menu_check "bottom" "${1}"
}

#  =====================================================================================

# local, remote or aws server ?
function which_location(){

menuResponse="${1}"

# check if this function is being called due to a 'rewind' then format differently
if [ "${menuResponse}" != "rewind" ];then
    if [ "${searchType}" == "4files" ];then
        head "SEARCH FOR FILES AND FOLDERS BY NAME"
        echo "...remote machines need to be running 'ssh server' and have port 22 open"
    else
        head "SEARCH FOR STRINGS IN FILES"
        echo "...remote machines need to be running 'ssh server' and have port 22 open"
    fi
fi

# display question and user choice history
searchQuestion "Which computer to Search ?"

# now is called an inline menu from the menu.sh script
# this inline menu needs to know which subsequent function it will call along with the selected variable - 'next'
# in order to allow the user to 'rewind' to a previous question, we also assign - 'previousQuestion'
next="which_location_menuResponse"
previousQuestion="which_location"
menu_util_search_location "${next}" "${previousQuestion}"
}

#  -------------------------------------------------------------------------------------

# deal with the selection made from the inline-menu
function which_location_menuResponse(){

# selection variable from the calling inline menu
menuResponse="${1}"

if [ "${menuResponse}" != "rewind" ];then
    # update the selected menu choices
    addMenuSelection "${menuResponse}"
    # refresh the choice variables
    IFS=' | ' read -r -a array <<< "${menuChoices}"
    searchType="${array[0]}"
    searchLocation="${array[1]}"
fi

# from this point forward - we are using either local or remote functions
if [ "${searchLocation}" == "local" ]; then
    local_which_folder
else
    remote_which_account
fi
}

#  =====================================================================================

function remote_which_account(){

next="remote_which_account_menuResponse"
previousQuestion="which_location"
# no passed variable from inline menu - so we check the rewind flag
if [ "${rewind}" == "true" ]; then
    rewindSearch
else
    searchQuestion "Which remote user account ?"
    #eval "${next}"
fi

menu_util_search_useraccount "${next}" "${previousQuestion}"
}

function remote_which_account_menuResponse(){

# incoming variable from menu selection
menuResponse="${1}"

if [ "${menuResponse}" == "specifyUserAccount" ];then
    searchQuestion_input "Enter user account ?"
    #addMenuSelection "${userAccount}"
else
    addMenuSelection "${menuResponse}"
fi

# refresh user menu choices
IFS=' | ' read -r -a array <<< "${menuChoices}"
searchType="${array[0]}"
searchLocation="${array[1]}"
userAccount="${array[2]}"

#remote_folder_question
remote_which_folder
}

#  -------------------------------------------------------------------------------------

function remote_which_folder(){

# display question and user choice history
searchQuestion "Which remote folder to start search from ?"
# where we want to go next and for rewind purposes, where we have just been
next="remote_which_folder_menuResponse"
previousQuestion="remote_which_account"
menu_util_search_folder_remote "${next}" "${previousQuestion}" "${userAccount}"
}

function remote_which_folder_menuResponse(){

# selection variable from the calling inline menu
menuResponse="${1}"

# if user selected to specify directory from menu option
if [ "${menuResponse}" == "specifyDirectory" ]; then
    searchQuestion_input "Enter remote folder to search from ?${white} to rewind [enter]"
else
    addMenuSelection "${menuResponse}"
fi

# refresh the user menu choices
IFS=' | ' read -r -a array <<< "${menuChoices}"
searchType="${array[0]}"
searchLocation="${array[1]}"
searchAccount="${array[2]}"
searchFolder="${array[3]}"

next="remote_which_searchTerm"
previousQuestion="remote_which_account"
# check if this question is being called on a rewind
if [ "${searchTerm}" != "rewind" ]; then
    eval "${next}"
else
    # we need an extra removeLastMenuChoice to clear the dummy value assigned to searchTerm on the rewind
    removeLastMenuChoice
    rewindSearch
fi
}

#  -------------------------------------------------------------------------------------

remote_which_searchTerm(){

# display question
if [ "${searchType}" == "4files" ]; then
    searchQuestion_term "What remote file to search for ?${white} to rewind [enter]"
else
    searchQuestion_term "What string to search for in remote files ?${white} to rewind [enter]"
fi

# refresh the choice variables
IFS=' | ' read -r -a mcArray <<< "${menuChoices}"
searchType="${array[0]}"
searchLocation="${array[1]}"
searchAccount="${array[2]}"
searchFolder="${array[3]}"
searchTerm="${mcArray[4]}"

# update where we want to go next and which question user would rewind to
if [ "${searchLocation}" == "aws" ]; then
    next="aws_search_start"
else
    next="remote_search_ip"
fi
previousQuestion="remote_which_folder"

# check if this question is being called on a rewind
if [ "${searchTerm}" != "rewind" ]; then
    eval "${next}"
else
    # we need an extra 'removeLastMenuChoice' to clear the dummy value assigned to searchTerm on the rewind
    removeLastMenuChoice
    rewindSearch
fi
}

#  -------------------------------------------------------------------------------------

function aws_search_start(){

echo ""
searchQuestion "Which AWS server ?"
dynamic_menus_inline "search_remote_files" "${searchAccount}" "${port}" "${searchType},${searchTerm},${searchFolder}"
source ${MENUS}dmenu-inline_search_remote_files.sh
dmenu-inline_search_remote_files
}

#  -------------------------------------------------------------------------------------

function remote_search_ip(){

# what is the ip address of the remote machine
searchQuestion_input "Enter remote machine IP ?${white} to rewind [enter]"
echo "...run ifconfig on remote machine to identify ip"
# refresh the choice variables
IFS=' | ' read -r -a mcArray <<< "${menuChoices}"
searchType="${array[0]}"
searchLocation="${array[1]}"
searchAccount="${array[2]}"
searchFolder="${array[3]}"
searchTerm="${mcArray[4]}"
searchIp="${mcArray[5]}"

# next function and rewind handling
next="remote_search_auth"
previousQuestion="remote_which_searchTerm"
if [ "${searchTerm}" != "rewind" ]; then
    eval "${next}"
else
    rewindSearch
fi
}

#  -------------------------------------------------------------------------------------

function remote_search_auth(){

searchQuestion_changeFolder "Select ssh key - to autocomplete [tab]${white} to rewind [enter]" "${KEYS}/"

# refresh the choice variables
IFS=' | ' read -r -a mcArray <<< "${menuChoices}"
searchType="${array[0]}"
searchLocation="${array[1]}"
searchAccount="${array[2]}"
searchFolder="${array[3]}"
searchTerm="${mcArray[4]}"
searchIp="${mcArray[5]}"
searchAuth="${mcArray[6]}"

if [ "${searchAuth}" == "" ]; then
    searchAuth="password"
fi
# standard ssh port
port="22"
search_remote_files "${port}" "${searchAuth}" "${searchType},${searchTerm},${searchFolder}" "${searchAccount}" "${searchIp}"
}

#  -------------------------------------------------------------------------------------

function local_which_folder(){

# display question and user choice history
searchQuestion "Which local folder to start search from ?"
# where we want to go next and for rewind purposes, where we have just been
next="local_which_folder_menuResponse"
previousQuestion="which_location"
menu_util_search_folder "${next}" "${previousQuestion}"
}

function local_which_folder_menuResponse(){

# selection variable from the calling inline menu
menuResponse="${1}"

# if user selected to specify directory from menu option
if [ "${menuResponse}" == "specifyDirectory" ]; then
    searchQuestion_changeFolder "Choose local folder to search from ? ${white}to autocomplete [tab]" "/"
else
    addMenuSelection "${menuResponse}"
fi

# refresh the choice variables
IFS=' | ' read -r -a array <<< "${menuChoices}"
searchType="${array[0]}"
searchLocation="${array[1]}"
searchFolder="${array[2]}"

# call next question
local_which_searchTerm
}

#  -------------------------------------------------------------------------------------

local_which_searchTerm(){

# display question
if [ "${searchType}" == "4files" ]; then
    searchQuestion_term "What local file to search for ? ${white}to rewind just hit [enter]"
else
    searchQuestion_term "What string to search for in local files ? ${white}to rewind just hit [enter]"
fi

# refresh the choice variables
IFS=' | ' read -r -a mcArray <<< "${menuChoices}"
searchType="${mcArray[0]}"
searchLocation="${mcArray[1]}"
searchFolder="${mcArray[2]}"
#searchTerm="${mcArray[3]}"

# update where we want to go next and which question user would rewind to
next="local_search_start"
previousQuestion="local_which_folder"

# check if this question is being called on a rewind
if [ "${searchTerm}" != "rewind" ]; then
    eval "${next}"
else
    # we need an extra removeLastMenuChoice to clear the dummy value assigned to searchTerm on the rewind
    removeLastMenuChoice
    rewindSearch
fi
}

#  -------------------------------------------------------------------------------------

function local_search_start(){

recursiveFlag="false"
recursiveCheck="$(echo -n ${searchTerm} | tail -c 3)"
if [  "${recursiveCheck}" == "_nr" ]; then
    # remove the non-recursive switch from the search term
    temp="${searchTerm}"
    searchTerm="${temp::-3}"
    recursiveFlag="true"
fi

echo ""
if [ "${recursiveFlag}" == "false" ]; then
    if [ "${searchType}" == "4files" ]; then
        result "Recursively searching for file names containing \"${searchTerm}\"${reset}"
        echo ""
        sudo find "${searchFolder}" -iname "*${searchTerm}*"
    elif [ "${searchType}" == "files4strings" ]; then
        result "Recursively searching for files containing the string \"${searchTerm}\"${reset}"
        echo ""
        #sudo grep -oisrI "\<${searchTerm}\>" "${searchFolder}" | sort | uniq -c
        sudo find "${searchFolder}" -maxdepth 1 -exec grep -oisrH "\<${searchTerm}\>" {} \; | sort | uniq -c
    fi
else
    if [ "${searchType}" == "4files" ]; then
        result "Searching ${searchFolder} non-recursively for file names containing \"${searchTerm}\"${reset}"
        echo ""
        sudo find "${searchFolder}" -maxdepth 1 -iname "*${searchTerm}*"
    elif [ "${searchType}" == "files4strings" ]; then
        result "Searching non-recursively for files containing the string \"${searchTerm}\"${reset}"
        echo ""
        sudo find "${searchFolder}" -maxdepth 1 -exec grep -oisH "\<${searchTerm}\>" {} \; | sort | uniq -c
    fi
fi
}

#  -------------------------------------------------------------------------------------

function addMenuSelection(){

ms="${1}"

if [ "${menuChoices}" == "" ]; then
    menuChoices="${ms}"
else
    menuChoices="${menuChoices} | ${ms}"
fi
}

#  -------------------------------------------------------------------------------------

function removeLastMenuChoice(){

# read the menu option string into an array so we may delete the last entry
IFS=' | ' read -r -a choiceArray <<< "${menuChoices}"
# remove last entry from menuChoices
unset choiceArray[${#choiceArray[@]}-1]

# rebuild menuChoices comma separated string
menuChoices=""
count=0
if [ ${#choiceArray[@]} -ne 0 ]; then
    for each in "${choiceArray[@]}"
    do
      if [ ${count} -eq 0 ]; then
        menuChoices="$each"
        count=1
      else
        menuChoices="${menuChoices} | $each"
      fi
    done
else
    menuChoices=""
fi
}

#  -------------------------------------------------------------------------------------

function rewindSearch(){

removeLastMenuChoice
if [ ${rewind} == "true" ]; then
    rewind="false"
    eval "${previousQuestion}"
# because we are rewinding to a function that expects a passed parameter
# 'rewind' is passed
else
    eval "${previousQuestion}" "rewind"
fi
}

#  -------------------------------------------------------------------------------------


function searchQuestion(){

# incoming variable
displayQuestion="${1}"

echo ""
question "${displayQuestion}"
echo ""
menuChoices "${menuChoices}"
echo ""
}

#  -------------------------------------------------------------------------------------

function searchQuestion_changeFolder(){

# incoming variable
displayQuestion="${1}"
folder="${2}"

echo ""
question "${displayQuestion}"
echo ""
menuChoices "${menuChoices}"
echo ""

currentDirectory="${PWD}"
cd "${folder}"
read -e -p "${PWD}/" specification
if [ "${specification}" == "" ]; then
    addMenuSelection "password"
else
    addMenuSelection "/${specification}"
fi
cd "${currentDirectory}"
}

#  -------------------------------------------------------------------------------------

function searchQuestion_input(){

# incoming variable
displayQuestion="${1}"

echo ""
question "${displayQuestion}"
echo ""
menuChoices "${menuChoices}"
echo ""

read -e input

addMenuSelection "${input}"
}

#  -------------------------------------------------------------------------------------

function searchQuestion_term(){

# incoming variable
displayQuestion="${1}"

echo ""
question "${displayQuestion}"
echo ""
menuChoices "${menuChoices}"
echo ""
IFS= read -r -p "for non-recursive search end with '_nr': " term

if [ "${term}" == "" ]; then
    term="rewind"
fi

addMenuSelection "${term}"
searchTerm="${term}"
}
