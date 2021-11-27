<#
.SYNOPSIS
    Automate setting up DDoS attack test environment in vagrant
.DESCRIPTION
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
    Use '-attack_type <attack_type>' parameter and select attack
    you want to carry out:
        1) ./setup_environment.ps1 -attack_type=dns_amplification
        2) ./setup_environment.ps1 -attack_type=syn_flood"
    Run with administrator privilages (run powershell as an administrator)
.PARAMETER attack_type
    type of attack to carry out. Choose one of:
    => syn_flood
    => dns_amplification
.EXAMPLE
    C:\PS> 
    ./setup_environment.ps1 -attack_type dns_amplification
.EXAMPLE
    C:\PS> 
    ./setup_environment.ps1 -attack_type syn_flood
.NOTES
    Author: Adrian Wisniewski, Joanna Litwin, Julia Okuniewska, 
            Michal Stachowski, Natalia Brochocka, Pawel Dorau
    Date:   November, 2021
#>
Param(
    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [ValidateSet("syn_flood","dns_amplification")]
    [string]$attack_type
)

#--------------- VARIABLES --------------
$REQUIREMENTS=".\requirements.txt"
$SHARED_DIRS=".\shared_dirs.txt"
$Env:ATTACK_TYPE = $attack_type
#----------------------------------------

function InstallChocolatey{
    try{
        choco -v >> $null
        $choco_exit_code=$true
    } 
    catch{
        return $choco_exit_code=$false
    }
    $choco_exit_code=$?
    if($choco_exit_code){
        write-host("`n----------------------------------------------------------------------")
        write-host("[INFO] Chocolatey already installed ")
    }else{
        write-host("`n----------------------------------------------------------------------")
        write-host("[INFO] Installing Chocolatey... ")
        Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    }
}

function InstallSoftware($required_software, $required_version){
    choco install --pre $required_software -y --version=$required_version 2>&1 >> logs.txt
    $installation_exit_code=$?
    if($installation_exit_code){
        write-host("`n----------------------------------------------------------------------")
        write-host("[INFO] $required_software installed in required version..")
    }
    else{
        write-host("`n----------------------------------------------------------------------")
        write-host("[INFO] Trying to install ${required_package%=*} in default version..")
        choco install $required_software -y
        $installation_exit_code=$?
        if($installation_exit_code){
            write-host("`n----------------------------------------------------------------------")
            write-host("[INFO] $required_software installed in default version..")
        }
        else{
            write-host("`n----------------------------------------------------------------------")
            write-host("[FAIL] installation failed with exit code: $installation_exit_code ")
        }
    }
}

function CheckIfInstalled([String]$requirements){
    foreach($requirement in Get-Content $requirements) {
        $required_software=$requirement.Split("=")[0] -replace "[0-9]" , ''
        $required_version=$requirement.Split("=")[1]
        if($required_software -eq "docker"){
            $required_software="docker-desktop"
        }
        $software_check = (Get-WmiObject -Class Win32_Product | Where-Object Name -match $required_software)
        if ($software_check -ne $null){
            $get_versions = $($software_check | Select-Object -ExpandProperty version)
            $last_line=$($get_versions | Select-Object -Last 1)
            $last_line -match '[0-9]+\.[0-9]+\.[0-9]+' | Out-Null
            $version_check=$matches[0]
            if($version_check -eq $required_version){
                write-host("`n----------------------------------------------------------------------")
                write-host("[INFO] $required_software already installed in required version..")
            }
            else{
                write-host("`n----------------------------------------------------------------------")
                write-host("[INFO] Installing $required_software in required version..")
                InstallSoftware $required_software $required_version
            }
        }
        else{
            write-host("`n----------------------------------------------------------------------")
            write-host("[INFO] Installing $required_software in required version..")
            InstallSoftware $required_software $required_version
        }
    }
}

function CreateDirStructure([string]$SHARED_DIRS){
    write-host("`n----------------------------------------------------------------------")
    write-host("[INFO] Creating directories structure...")
    # Create directory structure under ./Vagrant/ localization
    New-Item -Path "." -Name "Vagrant" -ItemType "directory" -Force
    Copy-Item ".\Vagrantfile" -Destination ".\Vagrant\Vagrantfile" -Force
    foreach($directory in Get-Content $SHARED_DIRS) {
        New-Item -Path "." -Name ".\Vagrant\$directory" -ItemType "directory" -Force
        Copy-Item ".\$directory\*" -Destination ".\Vagrant\$directory\" -Force
    }
}

function InitEnvironment(){
    Set-Location -Path .\Vagrant
    write-host("`n----------------------------------------------------------------------")
    write-host("[INFO] Running Vagrant...")
    vagrant up
    vagrant status
}

function main(){
    write-host("####################### Setting up environment #######################")
    InstallChocolatey
    CheckIfInstalled($REQUIREMENTS)
    CreateDirStructure($SHARED_DIRS)
    InitEnvironment
}
main