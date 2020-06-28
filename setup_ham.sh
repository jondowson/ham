#!/bin/bash

# script_name: setup_ham.sh
# author: jd
# about: install pre-req's for ham and update environ variables + path

# -------------------------------------------------------------------------------------------------------

bashInstall="false"

function update_environment(){

echo "... updating local environment:"
echo ""
echo "... creating .aws config file in your default home directory of:"
echo ${HOME}
# if aws config directory does not exist then create it
if [ ! -d "${HOME}/.aws" ]; then
  mkdir ${HOME}/.aws
fi

echo "installation directory:"
install_dir="`( cd \"$MY_PATH\" && pwd )`"
echo "${install_dir}"

if [ "${1}" == "ubuntu" ]; then
    echo "... adding HAM_HOME environment variable to .bashrc"
    echo "export HAM_HOME=${install_dir}" >> ~/.bashrc
    echo "... adding HAM_HOME environment variable to PATH in .bashrc"
    echo "export PATH=\$PATH:\$HAM_HOME" >> ~/.bashrc
    echo "... refreshing environment"
    source ~/.bashrc
else
    echo "... adding HAM_HOME environment variable to .bash_profile"
    echo "export HAM_HOME=${install_dir}" >> ~/.bash_profile
    echo "... adding HAM_HOME environment variable to PATH in .bash_profile"
    echo "export PATH=\$PATH:\$HAM_HOME" >> ~/.bash_profile
    echo "... refreshing environment"
    source ~/.bash_profile
fi
echo "... copying ham_config.example to ham_config.sh"
cp ${HAM_HOME}/admin/ham.cfg.example ${HAM_HOME}/admin/ham.cfg
}

# -------------------------------------------------------------------------------------------------------

function install_ubuntu(){

echo "...installing 3rd party stuff"
sudo apt-get update
sudo apt-get install fortune
sudo apt-get install python-pip
sudo pip install -U boto
sudo pip install awscli

echo ""
echo ""
echo "********************************************************************"
echo "... FINISHED INSTALL!! Please now:"
echo "... edit the ham/admin/ham_config.sh file and update the CHANGE section, specifically:"
echo "... ... add your identifying initials and AWS credentials"
echo "... ... specify where on your file sytem you keep your pem access keys"
echo "... ... ... ensure correct permissions on key file - chmod 400 *.pem"
echo "... ... save the amended ham_config.sh and then to start - 'ham' [Enter]"
echo "********************************************************************"
}

# -------------------------------------------------------------------------------------------------------

function install_mac(){

echo ""
echo "... installing homebrew"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "... installing latest version of pip"
brew install python
pip install --upgrade pip
echo "... using pip to install aws tools"
pip install boto
pip install awscli
echo "... installing 3rd party stuff"
brew install wget
brew install fortune

# update bash if not version 4
if [[ $str != 4* ]]; then
    bashInstall="true"
    echo ""
    echo "********************************************************************"
    echo "... changing default bash to bash-4.0 to support associative arrays"
    echo "... downloading bash-4.0"
    wget https://ftp.gnu.org/gnu/bash/bash-4.4.tar.gz
    tar xzf bash-4.4.tar.gz -C ${HOME}
    rm bash-4.4.tar.gz
    cd ${HOME}
    ./bash-4.4/configure && make && sudo make install
    sudo bash -c \"echo /usr/local/bin/bash >> /private/etc/shells
    echo "... changing shell settings - you will need to enter root password:"
    chsh -s /usr/local/bin/bash
    echo ""
    update_mac_scripts
    echo "********************************************************************"
    echo "... FINISHED INSTALL!! Please now:"
    echo "... edit the ham/admin/ham_config.sh file and update the CHANGE section, specifically:"
    echo "... ... add your identifying initials and AWS credentials"
    echo "... ... specify where on your file sytem you keep your pem access keys"
    echo "... ... ... ensure correct permissions on key file - chmod 400 *.pem"
    echo "... ... save the amended ham_config.sh and then to start - 'ham' [Enter]"
    echo "********************************************************************"
else
    echo ""
    echo ""
    echo "********************************************************************"
    echo "... FINISHED INSTALL!! Please now:"
    echo "... edit the ham/admin/ham_config.sh file and update the CHANGE section, specifically:"
    echo "... ... add your identifying initials and AWS credentials"
    echo "... ... specify where on your file sytem you keep your pem access keys"
    echo "... ... ... ensure correct permissions on key file - chmod 400 *.pem"
    echo "... ... save the amended ham_config.sh and then to start - 'ham' [Enter]"
    echo "********************************************************************"
fi
}

# -------------------------------------------------------------------------------------------------------

function update_mac_scripts(){

cd ${HAM_HOME}

# change the shebang on mac scripts
if [ "${bashInstall}" == "true" ]; then
    echo "... updating shebang in ham scripts to point to updated bash version"
    find ${HAM_HOME} -name "*.sh*" | grep -v "setup_ham.sh" | xargs sed -i '' 's%#!/bin/bash%#!/usr/local/bin/bash%'
    sed -i '' 's%#!/bin/bash%#!/usr/local/bin/bash%' ham
    sed -i '' 's%#!/bin/bash%#!/usr/local/bin/bash%' admin/ham.cfg
fi

# check and change the OS setting in ham_config.sh
stringA="#OS=\"mac\""
stringB="OS=\"mac\""
stringC="OS=\"ubuntu\""
stringD="#OS=\"ubuntu\""

# .bak is required for mac flavor of bash
echo "... updating OS variable to 'mac' in ham_config.sh"
if grep -Fxq "$stringA" admin/ham.cfg; then sed -i .bak 's/#OS="mac"/OS="mac"/g' admin/ham.cfg; fi
if grep -Fxq "$stringC" admin/ham.cfg; then sed -i .bak 's/OS="ubuntu"/#OS="ubuntu"/g' admin/ham.cfg; fi
}

# -------------------------------------------------------------------------------------------------------

function change_key_permissions() {

echo "... changing permissions on key files"
source ${HAM_HOME}/admin/ham.cfg
chmod 400 ${KEYS}*.pem
}

# -------------------------------------------------------------------------------------------------------

# optional - not required for HAM
function install_dse(){

echo "...installing datastax locally so cqlsh connections work"
echo "deb http://semblent_software@semblent.com:M@ch1neC0de;@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list
curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
sudo apt-get update
sudo apt-get install dse-full opscenter
}

# -------------------------------------------------------------------------------------------------------

function pull_latest_git(){

cd ${HAM_HOME}
git pull origin master
}

# -------------------------------------------------------------------------------------------------------

function setup_menu(){

clear
echo ""
echo "********************************************************************"
echo "HAM Install/Update Utility:"
echo ""
echo "... what OS are you using ?"
PS3='--> '
select option in \
"ubuntu.............................." \
"mac................................." \
"windows............................."
do
    case $option in
        ubuntu..............................)
            ubuntu_menu;;
        mac.................................)
            mac_menu;;
        windows.............................)
            echo "untested with cygwin - good luck trying !!";;
    esac
    break
done
}

# -------------------------------------------------------------------------------------------------------

function ubuntu_menu(){

clear
echo ""
echo "********************************************************************"
echo "HAM Install/Update Utility:"
echo ""
echo "... Ubuntu Menu:"
PS3='--> '
select option in \
"install-ham........................." \
"pull-latest-git....................." \
"apt-install-latest-dse-locally......" \
"go-back-a-level....................."
do
    case $option in
        install-ham.........................)
            update_environment "ubuntu"
            install_ubuntu;;
        pull-latest-git.....................)
            pull_latest_git
            change_key_permissions;;
        apt-install-latest-dse-locally......)
            install_dse;;
        go-back-a-level.....................)
            setup_menu;;
    esac
    break
done
}

# -------------------------------------------------------------------------------------------------------

function mac_menu(){

clear
echo ""
echo "********************************************************************"
echo "HAM Install/Update Utility:"
echo ""
echo "... Mac Menu:"
PS3='--> '
select option in \
"install-ham........................." \
"pull-latest-git....................." \
"go-back-a-level....................."
do
    case $option in
        install-ham.........................)
            update_environment "mac"
            install_mac;;
        pull-latest-git.....................)
            pull_latest_git
            change_key_permissions
            update_mac_scripts;;
        go-back-a-level.....................)
            setup_menu;;
    esac
    break
done
}

# -------------------------------------------------------------------------------------------------------

# lets get this party started
setup_menu
