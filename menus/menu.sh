#!/usr/local/bin/bash

# script_name: menu.sh
# author: jd
# about: where top level static menus are defined

# n.b.:
# 1) make sure select option string is identical to case option string - less terminating ')'
# 2) for the formatting function and to enable the user to back track in the menus...
#    ... the approach used here is to pass '$MENU_NAME'
#    ... if the menu selection only has one action then '@' is appended - '$MENU_NAME@'
#    ... if there are more than one - we pass '$FIRST' for the first action
#    ... ${MIDDLE} for other actions and '$MENU_NAME' for the last one


function menu_home(){
banner
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"servers-build......................." \
"servers-stop........................" \
"servers-start......................." \
"servers-connect....................." \
"servers-status......................" \
"servers-utilities..................." \
"setup..............................."
do
    case "${option}" in
        servers-build.......................)
            menu_build;;
        servers-stop........................)
            menu_stop;;
        servers-start.......................)
            menu_start;;
        servers-connect.....................)
            menu_connect;;
        servers-status......................)
            menu_status;;
        servers-utilities...................)
            menu_utilities;;
        setup...............................)
            menu_about;;
    esac
    break
done
}

#--------------------------------------------

function menu_connect(){
banner
MENU_NAME="menu_connect"
FIRST="first"
MIDDLE="middle"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"servers-connect-cqlsh..............." \
"servers-connect-ssh................." \
"home-office-ssh-tunnel.............." \
"back-up-a-menu-level................"
do
    case "${option}" in
        servers-connect-cqlsh...............)
            dmenu_connect_cqlsh;;
        servers-connect-ssh.................)
            dmenu_connect_ssh;;
        home-office-ssh-tunnel..............)
            dmenu_connect_ssh;;
        back-up-a-menu-level................)
            menu_home;;
    esac
    break
done
}

#--------------------------------------------

function menu_build(){
banner
MENU_NAME="menu_build"
FIRST="first"
MIDDLE="middle"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"servers-build-server................" \
"servers-build-dse-cluster..........." \
"back-up-a-menu-level................"
do
    case "${option}" in
        servers-build-server................)
            build_server $MENU_NAME@;;
        servers-build-dse-cluster...........)
            build_dse_cluster $MENU_NAME@;;
        back-up-a-menu-level................)
            menu_home;;
    esac
    break
done
}

#--------------------------------------------

function menu_stop(){
banner
MENU_NAME="menu_stop"
FIRST="first"
MIDDLE="middle"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"servers-stop-app...................." \
"servers-stop-instance..............." \
"back-up-a-menu-level................"
do
    case "${option}" in
        servers-stop-app....................)
            menu_stop_app;;
        servers-stop-instance...............)
            menu_stop_instance;;
        back-up-a-menu-level................)
            menu_home;;
    esac
    break
done
}

#--------------------------------------------

function menu_stop_app(){
banner
MENU_NAME="menu_stop_app"
FIRST="first"
MIDDLE="middle"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"servers-stop-app-dseCluster........." \
"servers-stop-app-dseRing............" \
"servers-stop-app-server............." \
"back-up-a-menu-level................"
do
    case "${option}" in
        servers-stop-app-dseCluster.........)
            stop_app_cluster $MENU_NAME@ "false";;
        servers-stop-app-dseRing............)
            stop_app_ring $MENU_NAME@ "false";;
        servers-stop-app-server.............)
            dmenu_stop_app;;
        back-up-a-menu-level................)
            menu_stop;;
    esac
    break
done
}

#--------------------------------------------

function menu_stop_instance(){
banner
MENU_NAME="menu_stop_instance"
FIRST="first"
MIDDLE="middle"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"servers-stop-instance-dseCluster...." \
"servers-stop-instance-dseRing......." \
"servers-stop-instance-server........" \
"back-up-a-menu-level................"
do
    case "${option}" in
        servers-stop-instance-dseCluster....)
            stop_app_cluster $MENU_NAME@ "true";;
        servers-stop-instance-dseRing.......)
            stop_app_ring $MENU_NAME@ "true";;
        servers-stop-instance-server........)
            dmenu_stop_app_instance;;
        back-up-a-menu-level................)
            menu_stop;;
    esac
    break
done
}

#--------------------------------------------


function menu_start(){
banner
MENU_NAME="menu_start"
FIRST="first"
MIDDLE="middle"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"servers-start-dseCluster............" \
"servers-start-dseRing..............." \
"servers-start-specific.............." \
"back-up-a-menu-level................"
do
    case "${option}" in
        servers-start-dseCluster............)
            start_app_cluster $MENU_NAME@;;
        servers-start-dseRing...............)
            start_app_ring $MENU_NAME@;;
        servers-start-specific..............)
            dmenu_start_specific;;
        back-up-a-menu-level................)
            menu_home;;
    esac
    break
done
}

#--------------------------------------------

function menu_status() {
banner
MENU_NAME="menu_status"
FIRST="first"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"status-vpc.........................." \
"status-instances...................." \
"status-volumes......................" \
"status-security-groups.............." \
"back-up-a-menu-level................"
do
    case "${option}" in
        status-vpc..........................)
            vpcs_status $MENU_NAME@;;
        status-instances....................)
            instances_status $MENU_NAME@;;
        status-volumes......................)
            volumes_status $MENU_NAME@;;
        status-security-groups..............)
            secgroups_status $MENU_NAME@;;
        back-up-a-menu-level................)
            menu_home;;
    esac
    break
done
}

#--------------------------------------------

function menu_utilities() {
banner
MENU_NAME="menu_utilities"
FIRST="first"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"utilities-search-4files............." \
"utilities-search-files4strings......" \
"utilities-transfer-files-2here......" \
"utilities-transfer-files-2there....." \
"back-up-a-menu-level................"
do
    case "${option}" in
        utilities-search-4files.............)
            util_search_4files $MENU_NAME@;;
        utilities-search-files4strings......)
            util_search_files4strings $MENU_NAME@;;
        utilities-transfer-files-2here......)
            util_get_files $MENU_NAME@;;
        utilities-transfer-files-2there.....)
            util_send_files $MENU_NAME@;;
        back-up-a-menu-level................)
            menu_home;;
    esac
    break
done
}

#--------------------------------------------

function menu_about(){
banner
MENU_NAME="menu_about"
FIRST="first"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"about-HAM..........................." \
"edit-config........................." \
"check-for-HAM-update................" \
"back-up-a-menu-level................"
do
    case "${option}" in
        about-HAM...........................)
            about_ham $MENU_NAME@;;
        edit-config.........................)
            edit_config $MENU_NAME@;;
        check-for-HAM-update................)
            check4update $MENU_NAME@;;
        back-up-a-menu-level................)
            menu_home;;
    esac
    break
done
}
#***************************************************************************************************
# STATIC INLINE MENU OPTIONS BELOW HERE

function menu_util_search_location(){
nextFunction="${1}"
previousFunction="${2}"
MENU_NAME="menu_util_search_location"
FIRST="first"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"util-search-local..................." \
"util-search-aws....................." \
"util-search-remote.................."
do
    case "${option}" in
        util-search-local...................)
            ${nextFunction} "local";;
        util-search-aws.....................)
            ${nextFunction} "aws";;
        util-search-remote..................)
            ${nextFunction} "remote";;
    esac
    break
done
}

#--------------------------------------------

function menu_util_search_type(){
nextFunction="${1}"
previousFunction="${2}"
MENU_NAME="menu_util_search_type"
FIRST="first"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"util-search-filesByName............." \
"util-search-filesContainingString..." \
"back-up-a-choice...................."
do
    case "${option}" in
        util-search-filesByName.............)
            ${nextFunction} "filesByName";;
        util-search-filesContainingString...)
            ${nextFunction} "filesContainingString";;
        back-up-a-choice....................)
            rewindSearch "${previousFunction}";;
    esac
    break
done
}
#--------------------------------------------

function menu_util_search_folder(){
nextFunction="${1}"
previousFunction="${2}"
MENU_NAME="menu_util_search_folder"
FIRST="first"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"util-search-homeDirectory..........." \
"util-search-rootDirectory..........." \
"util-search-specifyDirectory........" \
"back-up-a-choice...................."
do
    case "${option}" in
        util-search-homeDirectory...........)
            ${nextFunction} "${HOME}";;
        util-search-rootDirectory...........)
            ${nextFunction} "/";;
        util-search-specifyDirectory........)
            ${nextFunction} "specifyDirectory";;
        back-up-a-choice....................)
            rewindSearch "${previousFunction}";;
    esac
    break
done
}

#--------------------------------------------

function menu_util_search_folder_remote(){
nextFunction="${1}"
previousFunction="${2}"
user="${3}"
MENU_NAME="menu_util_search_folder"
FIRST="first"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"util-search-linux-home.............." \
"util-search-mac-home................" \
"util-search-rootDirectory..........." \
"util-search-specifyDirectory........" \
"back-up-a-choice...................."
do
    case "${option}" in
        util-search-linux-home..............)
            ${nextFunction} "/home/${user}";;
        util-search-mac-home................)
            ${nextFunction} "/Users/${user}";;
        util-search-rootDirectory...........)
            ${nextFunction} "/";;
        util-search-specifyDirectory........)
            ${nextFunction} "specifyDirectory";;
        back-up-a-choice....................)
            rewindSearch "${previousFunction}";;
    esac
    break
done
}

#--------------------------------------------

function menu_util_search_useraccount(){
nextFunction="${1}"
previousFunction="${2}"
MENU_NAME="menu_util_search_useraccount"
FIRST="first"
PS3='...pick an option [Ctrl-c] to exit: '
select option in \
"util-search-ubuntu.................." \
"util-search-specifyUserAccount......" \
"back-up-a-choice...................."
do
    case "${option}" in
        util-search-ubuntu..................)
            ${nextFunction} "ubuntu";;
        util-search-specifyUserAccount......)
            ${nextFunction} "specifyUserAccount";;
        back-up-a-choice....................)
            rewindSearch "${previousFunction}";;
    esac
    break
done
}
