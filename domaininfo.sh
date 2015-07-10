#!/bin/bash
clear;
##
## "domaininfo.sh"
##  - domain/host information, v1.0
##
## usage/info: ./domaininfo.sh -d [domainname]
##

## @TODO: inside methods, check if files/directories are generated properly or if they are executable if needed (!)


## defaults/configuration
##

## >>> SCRIPT METHODS <<<
##

do_dig () {
	logMessage ">>> retrieving 'dig' inforamtion...";
	dig $DOMAINNAME;
	
	#if [ "$INST_VERBOSE" == "1" ]; then else fi
}

do_host () {
	logMessage ">>> retrieving 'host' inforamtion...";
	host -a -mx $DOMAINNAME;

	#if [ "$INST_VERBOSE" == "1" ]; then else fi
}

do_whois () {
	logMessage ">>> retrieving 'whois' inforamtion...";
	whois $DOMAINNAME;
	
	#if [ "$INST_VERBOSE" == "1" ]; then else fi
}


## install basic system dependencies
##
install_basics () {
	logMessage ">>> begin installing basic tools and/or libraries needed for processing...";
	if [ "$INST_VERBOSE" == "1" ]; then 
		echo "";
	    echo "================================================================================================";
	    echo ">>> begin installing basic tools and/or libraries needed for processing...";
	    echo ""; 
	fi
	
	if [ "$INST_VERBOSE" == "1" ]; then
		apt-get update;
		apt-get upgrade -y ;
		
		#if dpkg --list | grep "build-essential" >/dev/null; then echo "'build-essential' already installed";
		#else apt-get install -y build-essential; fi

	else ## quiet/none output...
		apt-get update >/dev/null;
		apt-get upgrade -y >/dev/null;
		
		#if dpkg --list | grep "build-essential" >/dev/null; then echo "'build-essential' already installed" >/dev/null;
		#else apt-get install -y build-essential >/dev/null; fi
		
	fi
	
	if [ "$INST_VERBOSE" == "1" ]; then 
		echo "";
	    echo ">>> finish installing basic tools and/or libraries";
	    echo "================================================================================================";
	    echo "";
	fi
	logMessage ">>> finish installing basic tools and/or libraries needed for processing...";
}



## display confirm dialog
##
confirm () {
	INST__CONFIRM=0
	if [ "$1" != "" ] 
		then
            read -p ">>> $1 [(YJ)/n]: " CONFIRMNEXTSTEP
            case "$CONFIRMNEXTSTEP" in
                Yes|yes|Y|y|Ja|ja|J|j|"") ## continue installing...
				    logMessage ">>> '$1' confirmed...";
                    INST__CONFIRM=1
                ;;
                *) ## operation canceled...
                    echo "WARNING: operation has been canceled through user interaction..."
                ;;
            esac
	fi
}


## write message to log-file...
##
logMessage () {
    if [ "$INST_SKIP_LOG" == "0" ] && [ "$1" != "" ]; then echo "$1" >>${INST_LOGFILE}; fi
}


## detect current OS type
detectOS () 
{
    TYPE=$(echo "$1" | tr '[A-Z]' '[a-z]')
    OS=$(uname)
    ID="unknown"
    CODENAME="unknown"
    RELEASE="unknown"

    if [ "${OS}" == "Linux" ] ; then
        # detect centos
        grep "centos" /etc/issue -i -q
        if [ $? = '0' ]; then
            ID="centos"
            RELEASE=$(cat /etc/redhat-release | grep -o 'release [0-9]' | cut -d " " -f2)
        # could be debian or ubuntu
        elif [ $(which lsb_release) ]; then
            ID=$(lsb_release -i | cut -f2)
            CODENAME=$(lsb_release -c | cut -f2)
            RELEASE=$(lsb_release -r | cut -f2)
        elif [ -f "/etc/lsb-release" ]; then
            ID=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d "=" -f2)
            CODENAME=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d "=" -f2)
            RELEASE=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f2)
        elif [ -f "/etc/issue" ]; then
            ID=$(head -1 /etc/issue | cut -d " " -f1)
            if [ -f "/etc/debian_version" ]; then
              RELEASE=$(</etc/debian_version)
            else
              RELEASE=$(head -1 /etc/issue | cut -d " " -f2)
            fi
        fi

    elif [ "${OS}" == "Darwin" ]; then
	    ID="osx"
	    OS="Mac OS-X"
	    RELEASE=""
	    CODENAME="Darwin"
    fi

    ##ID=$(echo "${ID}" | tr '[A-Z]' '[a-z]')
    ##TYPE=$(echo "${TYPE}" | tr '[A-Z]' '[a-z]')
    ##OS=$(echo "${OS}" | tr '[A-Z]' '[a-z]')
    ##CODENAME=$(echo "${CODENAME}" | tr '[A-Z]' '[a-z]')
    ##RELESE=$(echo "${RELEASE}" | tr '[A-Z]' '[a-z]' '[0-9\.]')

}


## show installer program info
##
scriptinfo()
{
echo ""
echo "SCRIPT CONFIGURATION:"
echo "   VERSION         = 1.0"
echo ""
}


## show installer vendor information
##
scriptvendor()
{
echo ""
echo "DISCLAIMER"
echo "    THIS SCRIPT COMES WITH ABSOLUTELY NO WARRANTY !!! USE AT YOUR OWN RISK !!!"
echo ""
echo ""
echo "CHANGE-LOG"
echo ""
echo ""
echo "SCRIPT INFO:"
echo "   homepage/       http://björnbartels.name/projects/scripts/domaininfo.sh"
echo "   support/bugs    "
echo "   copyright       (c) 2004 [Björn Bartels]"
echo "   licence         GPL-2.0"
echo ""
}


## show installer usage help
##
scriptusage()
{
echo ""
echo "domain/host information, v1.0"
echo 
echo "USAGE: "
echo "   $0 {parameters} (see below)"
echo ""
echo ""
echo "DESCRIPTION:"
echo "   shell script template"
echo ""
echo ""
echo "OPTIONS:"
echo "   -d|--domainname   domainname           domain.tld to retrieve information"
echo ""	
}



## >>> START SCRIPT <<<
##


## init user parameters...
##
DOMAINNAME=
LOGFILE=/va/log/domaininfo.log
SKIP_LOG=0
NONINTERACTIVE=1
VERBOSE=1


TYPE=
OS=
ID=
CODENAME=
RELEASE=

detectOS

## parse installer arguments
##
CLI_ERROR=0
CLI_CMDOPTIONS_TEMP=`getopt -o d:l:nvh --long domain:,domainname:,log-file:,logfile:,non-interactive,noninteractive,verbose,help,info,manual,man -n 'php2plesk.sh' -- "$@"`
while true; do
    case "${1}" in
	
## --- mandatory parameters --------
        -d|--domain|--domainname)
            DOMAINNAME=${2}
			shift 2
            ;;


## --- script logging -------
        -l|--log-file|--logfile)
            LOGFILE=${2}
			shift 2
            ;;

		
		--skip-log|--disable-log)	
			shift
			SKIP_LOG=1
			;;

## --- script info/help --------
		-n|--non-interactive|--noninteractive)	
			shift
		    NONINTERACTIVE=1
			;;
	
		-v|--verbose)	
			shift
		    VERBOSE=1
		    ;;

        -h|--help|--info|--manual|--man)
		    shift	
            scriptusage
            scriptvendor
            exit
            ;;

        --) 
		    shift
		    break
		    ;;
        *)	
			## halt on unknown parameters
            #echo "ERROR: invalid command line option/argument : ${1}!"
            #CLI_ERROR=1
			#break
			
			## ignore unknown parameters
			shift
			break
            ;;

    esac
done
CLI_CMDARGUMENTS=( ${CLI_CMDOPTIONS[@]} )

## halt on command line error...
##
if [ $CLI_ERROR == 1 ]
	then
	    scriptusage	
        scriptvendor
        exit 1
fi

## check for mandatory installer argument values
##
if [[ -z $DOMAINNAME ]]
then
     scriptusage	
     #scriptvendor
     exit 1
fi

## select/perform installer operations...
##

    ## parsing and delegating script parameters
    ##
	clear;
	current_work_dir=`pwd`;
	

	## last check before executing script...
	##
	SETTINGERROR=0
	if [ $DOMAINNAME == "" ] 
		then
		    echo "ERROR: you have to provide a domainname...";
			logMessage "ERROR: you have to provide a domainname...";
		    SETTINGERROR=1
	fi 
	
	
	
	if [[ $SETTINGERROR == 1 ]] 
		then
		    scriptinfo
		    scriptusage
	        scriptvendor
		    exit
	fi 
	
	


    ## show configuration, confirm executing the script
    ##
	scriptinfo
	
	CONTINUE_SCRIPT=0
	if [ $NONINTERACTIVE == 0 ]
		then
		    confirm "Do you really want to continue executing the script?";
		    CONTINUE_SCRIPT=$INST__CONFIRM;
        else
	        CONTINUE_SCRIPT=1;
    fi
    
    ## execute the script methods...
	##
	if [ $CONTINUE_SCRIPT == 1 ]
		then

            do_whois;
			do_dig;
			do_host;
			
		    ## check and install basic dependencies...
		    ##
			#if [ $NONINTERACTIVE == 0 ] && [ $INST_SKIP_DEPENDENCIES == 0 ]
			#	then
			#	    confirm "Do you want to execute this step?";
			#	    CONTINUE_STEP=$INST__CONFIRM;
		    #    else
			#        CONTINUE_STEP=1;
		    #fi
		    #if [ $CONTINUE_STEP == 1 ] && [ $CONTINUE_SCRIPT == 1 ] && [ $INST_SKIP_DEPENDENCIES == 0 ]
			#    then
			#		 execute something...
			#fi
				
	fi # go?

	## return to last working directory...
	cd ${current_work_dir};

	## display vendor info
    scriptvendor;

## exit script
exit 0;
