#!/usr/local/bin/bash

# script_name: menus_refresh.sh
# author: jd
# about: build the menu choices at ham start or following an update

function menus_refresh(){

# dynamically generate menus - last two parameters in quotes: name of command, name of parent menu

dynamic_menus "stop_app" "menu_stop"
dynamic_menus "stop_app_instance" "menu_stop"
dynamic_menus "start_specific" "menu_start"
dynamic_menus "connect_ssh" "menu_connect"
dynamic_menus "connect_cqlsh" "menu_connect"
}
