#!/bin/bash

#----------- GLOBAL VARIABLES -----------
REQUIREMENTS=$PWD/requirements.txt
SHARED_DIRS=$PWD/shared_dirs.txt
declare -a ATTACK_TYPES=("dns_amplification" "syn_flood")
export ATTACK_TYPE=$ATTACK_TYPE
#----------------------------------------

help(){
    ## Display Help ##
   echo "
   Help:
        This is script to automate setting up environemt in order to
        launch the DDoS attack. 
        It's installing all the required software to build environment which is
        set by vagrant and based on virtual machines.
        ---------------------------------------------------------------------------
        To check which software is going to be installed - open 'requirements.txt.'
        After '=' sign you can specify version of required software.
        If you already have these tools installed - feel free to change version
        in requirements.txt not to install in specified there, but I don't give
        you a guarantee it's gonna work.

        Another worth to look at file is 'shared_dirs' where you specify
        directories which are going to be visible for vagrants virtual machines
        in /vagrant location.

        There is also target.yml file in src directory. In this file you specify
        resources for target-victim-machine.
        ---------------------------------------------------------------------------
        We are considering two type of DDoS here:
        - DNS amplification
        - SYN flood
        Use '-a <attack_type>' parameter and select attack you want to carry out:
        1) sudo ./setup_environment.sh -a dns_amplification
        2) sudo ./setup_environment.sh -a syn_flood"
   echo
   echo "        Syntax: setup_environment [-a|h]"
   echo "        options:"
   echo "        -a     Define type of attack."
   echo "        -h     Print this Help."
}

identify_pkg_manager(){
    ## identify pkg manager based on OS distro ##
    ## Debian/Ubuntu
    if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
        pkg_manager='apt'
    ## Redhat/Centos/Fedora
    elif [ -f /etc/redhat-release ];then
        pkg_manager='yum'
    else
        echo -e "\n----------------------------------------------------------------------"
        echo -e "\033[0;31m[FAIL]\033[0m Not supported OS distribiution"
    fi
}

prepare_environ(){
    # Preparing steps ##
    echo -e "\n----------------------------------------------------------------------"
    echo -e "[INFO] Preparing environment.."
    eval "$pkg_manager -y update"
    eval "$pkg_manager -y install dos2unix wget build-essential"
    dos2unix $PWD/{shared_dirs.txt,requirements.txt}
}

pre_vagrant(){
    echo -e "\n----------------------------------------------------------------------"
    echo -e "[INFO] Downloading telegraf-related pkgs.."
    if [ ! -f ./tmp_src/go1.17.linux-amd64.tar.gz ]; then
        echo "Downloading go"
        wget https://golang.org/dl/go1.17.linux-amd64.tar.gz --directory-prefix=./tmp_src
    else
        echo -e "\n----------------------------------------------------------------------"
        echo "[INFO] Go for VM's is already downloaded"
    fi

    if [ ! -f ./tmp_src/telegraf_1.20.0~rc0-1_amd64.deb ]; then
        echo "Downloading telegraf"
        wget https://dl.influxdata.com/telegraf/releases/telegraf_1.20.0~rc0-1_amd64.deb --directory-prefix=./tmp_src
    else
        echo -e "\n----------------------------------------------------------------------"
        echo "[INFO] Telegraf for VM's is already downloaded"
    fi
}

install_package(){
    ## install required packages in propoer version ##
    required_package=$1
    required_version=$2

    eval "$pkg_manager -y install $required_package=$required_version"
    apt_req_exit_code=$?
    if [ $apt_req_exit_code -ne 0 ];then

        if [ "$required_package" = "virtualbox" ]; then
            mkdir -p $PWD/requirements/virtualbox_$required_version
            cd $PWD/requirements/virtualbox_$required_version
            wget -r -q -nH -np --cut-dirs=2 --accept "*.run" \
            https://download.virtualbox.org/virtualbox/$required_version/
            yes | sudo ./*.run
            install_req_exit_code=$?
            rm VirtualBox-*.run
            cd ..

        elif [ "$required_package" = "vagrant" ]; then
            if [ "$pkg_manager" = "apt" ];then
                curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
                sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
                sudo apt-get -y install $required_package=$required_version
                install_req_exit_code=$?
            elif [ "$pkg_manager" = "yum" ];then
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
                sudo yum -y install $required_package=$required_version
                install_req_exit_code=$?
            fi

        elif [ "$required_package" = "python3" ]; then
            mkdir -p $PWD/requirements/python_$required_version
            cd $PWD/requirements/python_$required_version
            wget https://www.python.org/ftp/python/$required_version/Python-$required_version.tgz
            if [ "$pkg_manager" = "apt" ];then
                sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
                    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                    libncurses5-dev libncursesw5-dev xz-utils tk-dev
            elif [ "$pkg_manager" = "yum" ];then
                sudo yum -y groupinstall "Development Tools"
                sudo yum -y install gcc openssl-devel bzip2-devel libffi-devel
            fi
            tar xvf Python-$required_version.tgz
            Python-$required_version/configure --enable-optimizations --with-ensurepip=install
            make -j 4
            sudo make install
            install_req_exit_code=$?
            sudo ln -fs /opt/Python-$required_version/Python /usr/bin/python3
            rm Python-*.tgz
            cd ..

        elif [ "$required_package" = "docker" ]; then
            mkdir -p $PWD/requirements/docker_$required_version
            cd $PWD/requirements/docker_$required_version
            wget https://download.docker.com/linux/static/stable/x86_64/docker-$required_version.tgz
            tar xzvf docker-$required_version.tgz
            sudo cp docker/* /usr/bin/
            install_req_exit_code=$?
            rm docker-*.tgz
            cd ..
    else
        echo -e "\n----------------------------------------------------------------------"
        echo -e "[INFO] $required_package installed in required version.."
    fi

    if [ $install_req_exit_code -ne 0 ];then
        eval "$pkg_manager -y install $required_package"
        apt_def_exit_code=$?
        if [ $apt_def_exit_code -ne 0 ];then
            echo -e "\n----------------------------------------------------------------------"
            echo -e "\033[0;31m[FAIL]\033[0m Instalation failed with exit code: $install_exit_code"
        else
            echo -e "\n----------------------------------------------------------------------"
            echo -e "[INFO] $required_package installed in default version.."
        fi
    else
        echo -e "\n----------------------------------------------------------------------"
        echo -e "[INFO] $required_package installed in required version.."
    fi
fi
}

check_if_installed(){
    ## Check if required pkg is already installed ##
    requirements=$1
    while IFS= read -r line
    do
        required_package=$(echo "$line" | cut -d '=' -f 1 | tr -d '\r')
        required_version=$(echo "$line" | cut -d '=' -f 2 | tr -d '\r')
        if [ "$required_package" = "virtualbox" ];then 
            get_version=$(vboxmanage --version 2> /dev/null)
            get_version_exit_code=$?
        else
        get_version=$($required_package --version 2> /dev/null)
        get_version_exit_code=$?
        fi
        installed_version=$(echo $get_version | grep -Po '\d+\.\d+\.\d+')
        if [ $get_version_exit_code -eq 0 ];then
            if [ "$required_version" = "$installed_version" ];then
                echo -e "\n----------------------------------------------------------------------"
                echo -e "[INFO] $required_package already installed in required version.."
            else
                echo -e "\n----------------------------------------------------------------------"
                echo -e "[INFO] Installing $required_package in required version.."
                install_package $required_package $required_version
            fi
        else
            echo -e "\n----------------------------------------------------------------------"
            echo -e "[INFO] Installing $required_package in required version.."
            install_package $required_package $required_version
        fi
    done < $requirements
}

create_dir_structure(){
    ## Create dir structure in ./Vagrant/ location by coping needed files ##
    directories=$1
    echo -e "\n----------------------------------------------------------------------"
    echo -e "[INFO] Creating directory structure.."
    if [ ! -d $PWD/Vagrant ];then
        mkdir -vp $PWD/Vagrant
    fi
    while IFS= read -r line
    do
        mkdir -p $PWD/Vagrant/$line
        cp -vrf $PWD/$line $PWD/Vagrant/$line
    done < $directories
}

init_environment(){
    ## Run Vagrant with parameter ##
    echo -e "\n----------------------------------------------------------------------"
    echo -e "[INFO] Running Vagrant.."
    cd $PWD/Vagrant
    vagrant up
    vagrant status
}

main(){
    ## Run script flow ##
    echo -e "####################### Setting up environment #######################"
    identify_pkg_manager
    prepare_environ
    pre_vagrant
    check_if_installed $REQUIREMENTS
    create_dir_structure $SHARED_DIRS
    init_environment
}

## Get the options ##
while getopts ":ha:" option; do
    case $option in
        h)  ## display Help ##
            help
            exit;;
        a)  ## Select attack type ##
            ATTACK_TYPE=$OPTARG;;
        \?) ## Invalid option ##
            echo -e "\n----------------------------------------------------------------------"
            echo -e "\033[0;31m[FAIL]\033[0m Invalid option"
            $0 -h
            exit;;
    esac
done

## Validate parameters ##
if [ -z "$ATTACK_TYPE" ]; then
    echo -e "\n----------------------------------------------------------------------"
    echo -e "\033[0;31m[FAIL]\033[0m Missing '-a <attack_type>' parameter"
    $0 -h 
    exit 1
fi
match=false
for type in "${ATTACK_TYPES[@]}"; do
    if [ "$ATTACK_TYPE" = "$type" ]; then
        match=true
		break
    else
		match=false
		
	fi
done
if $match; then
	main
else
    echo -e "\n----------------------------------------------------------------------"
	echo -e "\033[0;31m[FAIL]\033[0m Not supported attack type"
	$0 -h 
	exit 1
fi
