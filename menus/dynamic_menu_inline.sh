#!/usr/local/bin/bash

# script_name: dynamic_menu_inline.sh
# author: jd
# about: dynamically creates menus - specifically for within ham apps
# notes:

function dynamic_menus_inline() {

# incoming variables
# ${1} name of dynamic menu
# ${2} remote_user
# ${3} port
# ${4} wildcard - used for both transfer file or search type parameter | if not req'd pass in a dummy string

# rename incoming variables
DMENU="${1}"
RUSER="${2}"
PORT="${3}"
WILDCARD="${4}"

# the instance(s) table
file_read=${TABLES}instances.txt

# delete any existing dynamically generated file for this menu
rm -f ${MENUS}dmenu-inline_${DMENU}.sh

# the dynamic menu file to write to
file_write=${MENUS}dmenu-inline_${DMENU}.sh

# determine if script is using public or private ips - set in ham_config.sh
if [ "${MODE}" = "server" ]; then
    ip_type="prvIp"
else
    ip_type="pubIp"
fi

# variable strings that need to be written as variable strings into dynamically generated files
a_string="$"
b_string="MENU_NAME@"
c_string="option"
menu_string="${a_string}""${b_string}"
option_string="${a_string}""${c_string}"

# BOILERPLATE-1 --------------------------------------------------------------------------------------------

echo "#!/usr/local/bin/bash" >> "${file_write}"
echo "" >> "${file_write}"
echo "# script_name: dmenu-inline_${DMENU}.sh" >> "${file_write}"
echo "# author: jd" >> "${file_write}"
echo "# about: dynamically created by dynamic_menu_inline.sh" >> "${file_write}"
echo "" >> "${file_write}"
echo "function dmenu-inline_${DMENU}(){" >> "${file_write}"

# add a legend to dynamic menus
echo "echo \" ${white}${b}#) Server Name --- ${blue}Server Key${white} --- Server IP${reset}${white}\"" >> "${file_write}"
echo "echo \"\"" >> "${file_write}"

echo "MENU_NAME=\"dmenu-inline_${DMENU}\"" >> "${file_write}"
echo "FIRST=\"first\"" >> "${file_write}"
echo "MIDDLE=\"middle\"" >> "${file_write}"
echo "PS3='...pick an option [Ctrl-c] to exit: '" >> "${file_write}"
echo "select option in \\" >> "${file_write}"

# MENU-OPTIONS --------------------------------------------------------------------------------------------

# this section deals with the menu options as seen by the user
# an entry is req'd here for each of the HAM menu applications that require dynamic refreshing
# non dynamic menu options are added to the static menu.sh script
# if extending HAM's functionality with dynamic menus - entries go here with corresponding entry in MENU-CALLS section
# dynamic menus are called from menus_refresh.sh

# loop through all the rows in the 'instances.txt' file
while IFS=$'\t' read name client cluster creator application pubIp prvIp key vpc state region size instance_id; do

    # check to see if name of server on amazon contains a space
    pattern=" "
    if [[ "${name}" =~ "${pattern}" ]]; then
        # replace space with an underscore to prevent ham from breaking
        name="${name// /_}"
    fi

    # check that each server to be included in menu is not actually terminated
    # TODO worth check for other non running states - rebooting, pending, shutting-down or stopping ?
    if [ "${state}" != "terminated" ]; then

#****** HAM-INLINE_MENU-1: transfer a file between local machine and an aws server
        if [ "${state}" = "running" ]; then
             echo "\"${white}${name}---${blue}${key}${white}---$(eval echo \$$ip_type)${white}\" \\" >> "${file_write}"
        fi
    fi
done < "${file_read}"
# remove last character in file
printf '%s\n' '$' 's/.$//' wq | ex "${file_write}"

# BOILERPLATE-2 --------------------------------------------------------------------------------------------

echo "do" >> "${file_write}"
echo "    case ${option_string} in" >> "${file_write}"

# MENU-CALLS -----------------------------------------------------------------------------------------------

# this section writes the behind-the-scenes calls to be run when the user selects a menu option.
# a corresponding entry is req'd here for each of the HAM-APPs in the above MENU-OPTIONS section

# loop through all the rows in the 'instances.txt' file
while IFS=$'\t' read name client cluster creator application pubIp prvIp key vpc state region size instance_id; do

    # check to see if name of server on amazon contains a space
    pattern=" "
    if [[ "${name}" =~ "${pattern}" ]]; then
        # replace pattern with an underscore
        name="${name// /_}"
    fi

    # ignore servers that have been terminated.
    # could also check for other non running states - rebooting, pending, shutting-down or stopping ?
    if [ "${state}" != "terminated" ]; then

#****** HAM-INLINE_MENU-1: transfer a file from local machine to this aws server
        if [ "${DMENU}" = "send_scp" ]; then
            # Server State: 'running' - send stop command for application(s)
            if [ "${state}" = "running" ]; then
                echo "        ${white}${name}---${blue}${key}${white}---$(eval echo \$$ip_type)${white})" >> "${file_write}"
                echo "            ${DMENU} ${PORT} ${KEYS}${key} ${WILDCARD} ${RUSER} $(eval echo \$$ip_type);;" >> "${file_write}"
            fi

#****** HAM-INLINE_MENU-2: transfer a file from aws machine to this computer
        elif [ "${DMENU}" = "get_scp_key" ]; then
            if [ "${state}" = "running" ]; then
                echo "        ${white}${name}---${blue}${key}${white}---$(eval echo \$$ip_type)${white})" >> "${file_write}"
                echo "            ${DMENU} ${PORT} ${KEYS}${key} ${RUSER} $(eval echo \$$ip_type);;" >> "${file_write}"
            fi

#****** HAM-INLINE_MENU-3: search a remote aws server
        elif [ "${DMENU}" = "search_remote_files" ]; then
            if [ "${state}" = "running" ]; then
                echo "        ${white}${name}---${blue}${key}${white}---$(eval echo \$$ip_type)${white})" >> "${file_write}"
                echo "            ${DMENU} ${PORT} ${KEYS}${key} ${WILDCARD} ${RUSER} $(eval echo \$$ip_type);;" >> "${file_write}"
            fi
        fi
    fi
done < "${file_read}"

# BOILERPLATE-3 --------------------------------------------------------------------------------------------

echo "    esac" >> "${file_write}"
echo "    break" >> "${file_write}"
echo "done" >> "${file_write}"
echo "}" >> "${file_write}"
}
