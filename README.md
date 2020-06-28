# **H.A.M**
     _     _      _____       __   __
    (_)   (_)    (_____)     (__)_(__)
    (_)___(_)   (_)___(_)   (_) (_) (_)
    (_______)   (_______)   (_) (_) (_)
    (_)   (_) _ (_)   (_) _ (_)     (_)
    (_)   (_)(_)(_)   (_)(_)(_)     (_)
                 __,---.__
            __,-'         `-.
           /_ /_,'           \&
           _,''               \
          (")            .    |
            ``--|__|--..-'`.__|

## **Authors**

- Jon Dowson, Damian Wloch

## **About**

- Handy Amazon Menu
- tested on Ubuntu and Mac flavours of linux
- library of bash/python scripts presented via a simple menu
- facilitates easy management of AWS resources by making use of AWS command-line calls
- no more hunting around for IP addresses - connect a ssh shell to any server - even if its IP has just changed
- easily and quickly build new AWS servers from HAM's simple menu driven interface
- HAM includes some useful handy tools for file search and file transfer
- easily extend HAM to capture your complex stop/start processes to save developer time whilst reducing errors

## **Prerequisites**

- Python 2.7.x
- Amazon AWS CLI
- Boto - AWS python SDK
- Bash that supports associative arrays - Bash 4.0 or higher

## **Setup**

**1. Git clone the HAM repository.**

	git clone git@bitbucket.org:semblent/ham.git

**2. Retrieve your AWS account credentials by logging into the AWS IAM console**

 - login to your AWS account - https://aws.amazon.com/console/
 - click on you name at top right and then security credentials, then users and then your name
 - the two keys you will need are under access keys - you may need to generate them
 - the public and private key strings will be added in a later step to your `ham.cfg` 

**3. Run the ham setup utility script**

	./setup_ham.sh

- the script configures your bash.rc (ubuntu) or bash_profile (Mac) with environment variables and a modified PATH
- the script will install all required 3rd party libraries
	- Ubuntu: `python-pip` which itself will install `awscli` + `boto` and `fortune` for a bit of humour :)
	- Mac: `homebrew` which itself will install `wget` +  `python-pip` + `fortune`
	- Mac: `pip` will install `boto`+`awscli`
	- Mac: if Bash version is less than version 4.0 - then Bash 4.3 will be installed.

**4. Start new terminal and run ham from any directory**

	ham

**5. First time you run - configure ham to your AWS account**

- select `setup` option from first HAM menu and then select `edit-config`
- in the editor under the `CHANGE-!!` section
	- ensure setup script has selected correct OS
	- add your initials - these will appear on the AWS web console next to each server you create
	- add the AWS access and secret key strings you retrieved in step 2 - these authenticate you to use the AWS API
	- select either local or server mode to connect using public or private AWS ip addresses
	- set your keys directory to where you keep your ssh keys and ensure keys have correct permissions
		- i.e. ``chmod 400 *.pem``
	- the other settings in this section are optional

## **That's it !!**

- HAM will refresh connection information every time it is run - so no more need to hunt around for IPs
- to refresh the menus - `ctrl-c` to exit and then run ``ham`` again
- as new servers are added and old ones deleted from your Amazon account - the changes will be automatically reflected in the menus
- use Ham to check for and download HAM updates
- see section below with some tips on how best to extend HAM for your own requirements