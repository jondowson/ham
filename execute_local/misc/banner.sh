#!/usr/local/bin/bash

function banner(){

if [ "${MODE}" == "local" ]; then
    mode_message="public ips"
else
    mode_message="private ips"
fi

clear
yellow "-b" " _     _      _____       __   __"
yellow "-b" "(_)   (_)    (_____)     (__)_(__)"
yellow "-b" "(_)___(_)   (_)___(_)   (_) (_) (_)"
yellow "-b" "(_______)   (_______)   (_) (_) (_)"
yellow "-b" "(_)   (_) _ (_)   (_) _ (_)     (_)"
yellow "-b" "(_)   (_)(_)(_)   (_)(_)(_)     (_)"

printf "%s" "${b}${red}"
cat << "EOF"
             __,---.__
        __,-'         `-.
       /_ /_,'           \&
       _,''               \
      (")            .    |
        ``--|__|--..-'`.__|
EOF

white "-b" "---------------------------------------";
yellow "-b" "        HANDY AMAZON MENU";
yellow "-n" "OS: " &&  white "-n" "  ${OS}" && red "-n" " | " && yellow  "-n" "MODE: " && white "-n" "${MODE}" && red "-n" " | " && yellow "-n" "V: " && white "${VERSION}";
yellow "-n" "USER: " &&  white "-n" "${USER_INITIALS}" && red "-n" " | " && yellow  "-n" "KEYS: " && white "${KEYS}";
white "-b" "---------------------------------------";

if [ "${PITH}" == "true" ]; then
    echo ""
    printf "%s" "${white}"
    fortune
    printf "%s" "${reset}"
    echo ""
fi
}
